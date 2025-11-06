"""
Codebase Genius - Backend (v1)
Structured like Agentic-AI/task_manager/byllm/BE/v1
"""

import from byllm.llm { Model }
import from dotenv { load_dotenv }
import os;
import json;
include utils;
include agents.repo_mapper;
include agents.code_analyzer;
include agents.doc_genie;


# Global LLM model (choose provider via .env)
glob llm = Model(
    model_name="gemini/gemini-2.0-flash", verbose=False
);


node Repository {
    has url: str = "";
    has name: str = "";
    has local_path: str = "";
    has file_tree: dict = {};
    has readme_summary: str = "";
    has status: str = "initialized";
    has error: str = "";
    has documentation_path: str = "";
    has session_token: str = "";
}


# POST /codebase_genius
walker codebase_genius {
    has repo_url: str = "";

    obj __specs__ {
        static has auth: bool = False;
    }

    can execute with `root entry {
        if not self.repo_url or not is_valid_github_url(self.repo_url) {
            report {"error" : "Invalid GitHub repository URL" } ;
            disengage;
        }
        repo_name = extract_repo_name(self.repo_url);
        repo_nodes = here ++> Repository(url=self.repo_url, name=repo_name);
        repo = repo_nodes[0];
        repo.session_token = generate_token();
        # Step 1: map
        mapper_nodes = here ++> RepoMapper();
        mapper = mapper_nodes[0];
        mapper ++> repo;
        map_result = mapper.run_agent(repo);
        if not map_result.get("success", False) {
            err_msg = map_result.get("error", repo.error);
            if not err_msg {
                err_msg = "Failed to map repository";
            }
            report {"error" : err_msg } ;
            disengage;
        }
        # Step 2: analyze
        analyzer_nodes = here ++> CodeAnalyzer();
        analyzer = analyzer_nodes[0];
        analyzer ++> repo;
        analyze_result = analyzer.run_agent(repo);
        if not analyze_result.get("success", False) {
            err_msg = analyze_result.get("error", repo.error);
            if not err_msg {
                err_msg = "Failed to analyze repository";
            }
            report {"error" : err_msg } ;
            disengage;
        }
        # Step 3: generate docs
        docgen_nodes = here ++> DocGenie();
        docgen = docgen_nodes[0];
        docgen ++> repo;
        docgen ++> analyzer;
        doc_result = docgen.run_agent(repo, analyzer);
        if not doc_result.get("success", False) {
            err_msg = doc_result.get("error", repo.error);
            if not err_msg {
                err_msg = "Documentation generation failed";
            }
            report {"error" : err_msg } ;
            disengage;
        }
        report
        {"success" : True , "repository" : repo.name , "url" : repo.url , "status" : repo.status , "documentation_path" : repo.documentation_path , "readme_summary" : repo.readme_summary , "file_count" : len(
            repo.file_tree.get("files", [])
        ) , "analysis_files" : len(analyzer.analysis_results) } ;
    }
}


# GET /repositories
walker repositories {
    obj __specs__ {
        static has auth: bool = False;
    }

    can execute with `root entry {
        # Avoid querying internal Jaseci datastore to prevent stale/invalid
        # archetype errors. Instead, derive repository history from the
        # generated outputs directory which stores documentation per-repo.
        root_dir = os.path.abspath(os.path.join(os.getcwd(), ".."));
        out_dir = os.path.join(root_dir, "outputs");
        result = [];
        if not os.path.exists(out_dir) {
            report result ;
            disengage;
        }
        for name in os.listdir(out_dir) {
            entry_dir = os.path.join(out_dir, name);
            if not os.path.isdir(entry_dir) {
                continue;
            }
            docs_path = os.path.join(entry_dir, "docs.md");
            metadata_path = os.path.join(entry_dir, "metadata.json");
            repo_name = name.replace("_", "/");
            repo_url = "";
            readme_summary = "";
            status = "documented";
            if os.path.exists(metadata_path) {
                with open(metadata_path, 'r', encoding='utf-8') as meta_file {
                    metadata = json.loads(meta_file.read());
                }
                repo_name = metadata.get("name", repo_name);
                repo_url = metadata.get("url", "");
                readme_summary = metadata.get("readme_summary", "");
                status = metadata.get("status", status);
                docs_path = metadata.get("documentation_path", docs_path);
            } elif not os.path.exists(docs_path) {
                status = "mapped";
                docs_path = "";
            }
            result.append(
                {"name" : repo_name , "url" : repo_url , "status" : status , "documentation_path" : docs_path , "readme_summary" : readme_summary , "error" : "" }
            );
        }
        report result ;
    }
}


# GET /health
walker health {
    obj __specs__ {
        static has auth: bool = False;
    }

    can execute with `root entry {
        report {"status" : "healthy" , "service" : "Codebase Genius" } ;
    }
}


with entry {
    # Resolve project root (one level up from Backend)
    root_dir = os.path.abspath(os.path.join(os.getcwd(), ".."));
    dotenv_path = os.path.join(root_dir, ".env");
    if os.path.exists(dotenv_path) {
        load_dotenv(dotenv_path);
    } else {
        load_dotenv();
    }
    # Ensure project-root temp and outputs directories exist
    temp_dir = os.path.join(root_dir, "temp_repos");
    out_dir = os.path.join(root_dir, "outputs");
    if not os.path.exists(temp_dir) {
        os.makedirs(temp_dir);
    }
    if not os.path.exists(out_dir) {
        os.makedirs(out_dir);
    }
}
