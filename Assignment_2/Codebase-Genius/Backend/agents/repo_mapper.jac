"""
Repo Mapper Agent - clones repo and builds file tree
"""

import os;
import subprocess;
import shutil;


node RepoMapper {
    def summarize_readme(readme_content: str) -> str {
        lines = readme_content.split('\n');
        preview = lines[:5];
        summary = "\n".join(preview).strip();
        if not summary {
            summary = "README detected but content is empty.";
        }
        return summary;
    }

    can execute with codebase_genius entry {
        repo_list = [here-->( ` ? Repository ) ];
        if not repo_list {
            repo_list = [root-->( ` ? Repository ) ];
        }
        if not repo_list {
            report {"error" : "Repository context missing" } ;
            disengage;
        }
        repo = repo_list[len(repo_list) - 1];
        repo.status = "mapping";
        repo.error = "";
        repo_name = repo.name.replace("/", "_");
        root_dir = os.path.abspath(os.path.join(os.getcwd(), ".."));
        target_path = os.path.join(root_dir, "temp_repos", repo_name);
        clone_result = self.clone_repository(repo.url, target_path);
        if not clone_result["success"] {
            repo.status = "error";
            repo.error = clone_result.get("error", "Git clone failed");
            report {"error" : repo.error } ;
            disengage;
        }
        repo.local_path = target_path;
        repo.file_tree = self.build_file_tree(target_path);
        readme_content = self.find_readme_content(target_path);
        if readme_content {
            repo.readme_summary = self.summarize_readme(readme_content);
        } else {
            repo.readme_summary = "No README file found";
        }
        repo.status = "mapped";
    }

    def clone_repository(url: str, target_dir: str) -> dict {
        try {
            if os.path.exists(target_dir) {
                shutil.rmtree(target_dir);
            }
            result = subprocess.run(
                ["git", "clone", "--depth", "1", url, target_dir],
                capture_output=True,
                text=True,
                timeout=300
            );
            if result.returncode == 0 {
                return {"success" : True };
            }
            error_msg = result.stderr;
            if not error_msg {
                error_msg = "Git clone failed";
            }
            return {"success" : False , "error" : error_msg };
        } except Exception as e {
            return {"success" : False , "error" : str(e) };
        }
    }

    def build_file_tree(repo_path: str) -> dict {
        ignore_dirs = {".git","__pycache__","node_modules",".vscode"};
        tree = {"files" : [] };
        try {
            for walk_item in os.walk(repo_path) {
                files = walk_item[2];
                for file in files {
                    if file.startswith('.') {
                        continue;
                    }
                    rel_path = os.path.relpath(
                        os.path.join(walk_item[0], file), repo_path
                    );
                    rel_path = rel_path.replace("\\", "/");
                    parts = rel_path.split("/");
                    should_ignore = False;
                    for p in parts {
                        if p in ignore_dirs {
                            should_ignore = True;
                            break;
                        }
                    }
                    if should_ignore {
                        continue;
                    }
                    tree["files"].append(rel_path);
                }
            }
        } except Exception {
            tree["error"] = "Failed to scan directory";
        }
        return tree;
    }

    def find_readme_content(repo_path: str) -> str {
        readme_files = ["README.md", "README.rst", "README.txt"];
        for readme_file in readme_files {
            readme_path = os.path.join(repo_path, readme_file);
            if os.path.exists(readme_path) {
                try {
                    with open(readme_path, 'r', encoding='utf-8') as f {
                        return f.read();
                    }
                } except Exception {
                    continue;
                }
            }
        }
        return "";
    }

    def run_agent(repo: any) -> dict {
        try {
            if not repo or not repo.url {
                repo.status = "error";
                repo.error = "Repository URL missing";
                return {"success" : False , "error" : repo.error };
            }
            repo.status = "mapping";
            repo.error = "";
            repo_name = repo.name;
            if not repo_name {
                repo_name = repo.url.replace("https://github.com/", "").replace(
                    "/", "_"
                );
            }
            root_dir = os.path.abspath(os.path.join(os.getcwd(), ".."));
            target_path = os.path.join(root_dir, "temp_repos", repo_name);
            clone_result = self.clone_repository(repo.url, target_path);
            if not clone_result["success"] {
                repo.status = "error";
                repo.error = clone_result.get("error", "Git clone failed");
                return {"success" : False , "error" : repo.error };
            }
            repo.local_path = target_path;
            repo.file_tree = self.build_file_tree(target_path);
            readme_content = self.find_readme_content(target_path);
            if readme_content {
                repo.readme_summary = self.summarize_readme(readme_content);
            } else {
                repo.readme_summary = "No README file found";
            }
            repo.status = "mapped";
            return {"success" : True , "path" : repo.local_path };
        } except Exception as e {
            repo.status = "error";
            repo.error = str(e);
            return {"success" : False , "error" : repo.error };
        }
    }
}


sem RepoMapper. summarize_readme= """
Summarize the README content into a concise overview including:
1. Project purpose and main functionality
2. Key features
3. Technology stack
Keep it under 150 words.
""";
