"""
Doc Genie Agent - generates final markdown documentation
"""

import os;
import json;


node DocGenie {
    has target_repo_url: str = "";
    has target_repo_token: str = "";

    def select_repo(repo_list: list) -> any {
        if not repo_list {
            return None;
        }
        if self.target_repo_token {
            for candidate in repo_list {
                if candidate.session_token == self.target_repo_token {
                    return candidate;
                }
            }
        }
        if self.target_repo_url {
            for candidate in repo_list {
                if candidate.url == self.target_repo_url {
                    return candidate;
                }
            }
        }
        return repo_list[len(repo_list) - 1];
    }

    def resolve_repo()  -> any {
        repo_list = [here-->( ` ? Repository ) ];
        repo = self.select_repo(repo_list);
        if repo {
            return repo;
        }
        repo_list = [root-->( ` ? Repository ) ];
        repo = self.select_repo(repo_list);
        return repo;
    }

    def select_analyzer(analyzer_list: list) -> any {
        if not analyzer_list {
            return None;
        }
        if self.target_repo_token {
            for candidate in analyzer_list {
                analyzing_repo = [candidate-->( ` ? Repository ) ];
                for repo in analyzing_repo {
                    if repo.session_token == self.target_repo_token {
                        return candidate;
                    }
                }
            }
        }
        return analyzer_list[len(analyzer_list) - 1];
    }

    def resolve_analyzer()  -> any {
        analyzer_list = [here-->( ` ? CodeAnalyzer ) ];
        analyzer = self.select_analyzer(analyzer_list);
        if analyzer {
            return analyzer;
        }
        analyzer_list = [root-->( ` ? CodeAnalyzer ) ];
        analyzer = self.select_analyzer(analyzer_list);
        return analyzer;
    }

    def run_agent(repo: any, analyzer: any) -> dict {
        if repo.status != "analyzed" {
            return {"success" : False , "error" : "Repository must be analyzed first" };
        }
        doc_content = self.generate_documentation_content(
            repo.name, repo.readme_summary, analyzer.analysis_results
        );
        root_dir = os.path.abspath(os.path.join(os.getcwd(), ".."));
        output_dir = os.path.join(root_dir, "outputs", repo.name.replace('/', '_'));
        if not os.path.exists(output_dir) {
            os.makedirs(output_dir);
        }
        doc_path = os.path.join(output_dir, "docs.md");
        with open(doc_path, 'w', encoding='utf-8') as f {
            f.write(doc_content);
        }
        metadata = {"name" : repo.name , "url" : repo.url , "documentation_path" : doc_path , "status" : "documented" , "readme_summary" : repo.readme_summary };
        metadata_path = os.path.join(output_dir, "metadata.json");
        with open(metadata_path, 'w', encoding='utf-8') as meta_file {
            meta_file.write(json.dumps(metadata));
        }
        repo.documentation_path = doc_path;
        repo.status = "documented";
        repo.error = "";
        return {"success" : True , "documentation_path" : doc_path , "readme_summary" : repo.readme_summary };
    }

    def generate_documentation_content(
        repo_name: str, readme_summary: str, analysis_results: list
    ) -> str {
        sections = [];
        overview = "# Documentation for " + repo_name + "\n\n";
        if readme_summary {
            overview += "## Project Overview\n" + readme_summary + "\n\n";
        } else {
            overview += "## Project Overview\nNo README summary available.\n\n";
        }
        sections.append(overview);
        structure = "## Code Structure\n";
        if analysis_results {
            for record in analysis_results {
                path = record.get("path", "");
                details = record.get("details", {});
                structure += "- `" + path + "`\n";
                lang = details.get("language", "");
                if lang {
                    structure += "  - Language: " + lang + "\n";
                }
                funcs = details.get("functions", []);
                if funcs {
                    structure += "  - Functions: " + ", ".join(
                        [f.get("name", "") for f in funcs]
                    ) + "\n";
                }
                classes = details.get("classes", []);
                if classes {
                    structure += "  - Classes: " + ", ".join(
                        [c.get("name", "") for c in classes]
                    ) + "\n";
                }
                nodes = details.get("nodes", []);
                if nodes {
                    structure += "  - Nodes: " + ", ".join(
                        [n.get("name", "") for n in nodes]
                    ) + "\n";
                }
                walkers = details.get("walkers", []);
                if walkers {
                    structure += "  - Walkers: " + ", ".join(
                        [w.get("name", "") for w in walkers]
                    ) + "\n";
                }
                structure += "\n";
            }
        } else {
            structure += "No analysable files detected.\n\n";
        }
        sections.append(structure);
        usage = "## Usage Notes\nGenerated without LLM assistance. Review and expand as needed.\n";
        sections.append(usage);
        return "".join(sections);
    }

    can execute with codebase_genius entry {
        repo = self.resolve_repo();
        if not repo {
            report {"error" : "Repository context missing" } ;
            disengage;
        }
        if repo.status != "analyzed" {
            report {"error" : "Repository must be analyzed first" } ;
            disengage;
        }
        analyzer = self.resolve_analyzer();
        if not analyzer {
            report {"error" : "Code analyzer results not found" } ;
            disengage;
        }
        doc_content = self.generate_documentation_content(
            repo.name, repo.readme_summary, analyzer.analysis_results
        );
        # Write docs under project root outputs
        root_dir = os.path.abspath(os.path.join(os.getcwd(), ".."));
        output_dir = os.path.join(root_dir, "outputs", repo.name.replace('/', '_'));
        if not os.path.exists(output_dir) {
            os.makedirs(output_dir);
        }
        doc_path = os.path.join(output_dir, "docs.md");
        with open(doc_path, 'w', encoding='utf-8') as f {
            f.write(doc_content);
        }
        metadata = {"name" : repo.name , "url" : repo.url , "documentation_path" : doc_path , "status" : "documented" , "readme_summary" : repo.readme_summary };
        metadata_path = os.path.join(output_dir, "metadata.json");
        with open(metadata_path, 'w', encoding='utf-8') as meta_file {
            meta_file.write(json.dumps(metadata));
        }
        repo.documentation_path = doc_path;
        repo.status = "documented";
        repo.error = "";
    }
}


sem DocGenie. generate_documentation_content= """
Generate comprehensive markdown documentation that includes:

1. Project Overview - Based on the README summary and repository name
2. Installation Instructions - Basic setup steps
3. Code Structure - Overview of files and their purposes
4. API Reference - List all functions, classes, nodes, and walkers found in the analysis
5. Usage Examples - Basic usage patterns

Format as proper markdown with headers, code blocks, and clear sections.
Keep it informative but concise.
""";
