"""
Code Analyzer Agent - inspects repository source files
"""

import os;
import ast;


node CodeAnalyzer {
    has analysis_results: list = [];

    def analyze_repository(repo_path: str) -> list {
        results = [];
        for walk_entry in os.walk(repo_path) {
            current_dir = walk_entry[0];
            files = walk_entry[2];
            for file_name in files {
                lower_name = file_name.lower();
                if not (lower_name.endswith(".py") or lower_name.endswith(".jac")) {
                    continue;
                }
                absolute_path = os.path.join(current_dir, file_name);
                rel_path = os.path.relpath(absolute_path, repo_path);
                rel_path = rel_path.replace("\\", "/");
                if lower_name.endswith(".py") {
                    details = self.parse_python_file(absolute_path);
                } else {
                    details = self.parse_jac_file(absolute_path);
                }
                results.append({"path" : rel_path , "details" : details });
            }
        }
        return results;
    }

    def parse_python_file(file_path: str) -> dict {
        details = {"language" : "python" , "functions" : [] , "classes" : [] };
        try {
            with open(file_path, 'r', encoding='utf-8') as f {
                source = f.read();
            }
            module = ast.parse(source, filename=file_path);
            for node in module.body {
                if isinstance(node, ast.FunctionDef) {
                    func_info = {"name" : node.name };
                    doc = ast.get_docstring(node);
                    if doc {
                        func_info["docstring"] = doc;
                    }
                    details["functions"].append(func_info);
                } elif isinstance(node, ast.AsyncFunctionDef) {
                    func_info = {"name" : node.name , "async" : True };
                    doc = ast.get_docstring(node);
                    if doc {
                        func_info["docstring"] = doc;
                    }
                    details["functions"].append(func_info);
                } elif isinstance(node, ast.ClassDef) {
                    class_info = {"name" : node.name , "methods" : [] };
                    doc = ast.get_docstring(node);
                    if doc {
                        class_info["docstring"] = doc;
                    }
                    for class_node in node.body {
                        if isinstance(class_node, ast.FunctionDef) {
                            class_info["methods"].append(class_node.name);
                        } elif isinstance(class_node, ast.AsyncFunctionDef) {
                            class_info["methods"].append(class_node.name + " (async)");
                        }
                    }
                    details["classes"].append(class_info);
                }
            }
        } except Exception as e {
            details["error"] = str(e);
        }
        return details;
    }

    def parse_jac_file(file_path: str) -> dict {
        details = {"language" : "jac" , "nodes" : [] , "walkers" : [] };
        try {
            with open(file_path, 'r', encoding='utf-8') as f {
                lines = f.readlines();
            }
            idx = 0;
            while idx < len(lines) {
                raw_line = lines[idx];
                stripped = raw_line.strip();
                if stripped.startswith("node ") {
                    node_name = self.extract_identifier(stripped, "node");
                    if node_name {
                        details["nodes"].append({"name" : node_name });
                    }
                } elif stripped.startswith("walker ") {
                    walker_name = self.extract_identifier(stripped, "walker");
                    if walker_name {
                        details["walkers"].append({"name" : walker_name });
                    }
                }
                idx = idx + 1;
            }
        } except Exception as e {
            details["error"] = str(e);
        }
        return details;
    }

    def extract_identifier(line: str, keyword: str) -> str {
        remainder = line[len(keyword):].strip();
        if not remainder {
            return "";
        }
        tokens = remainder.split();
        identifier = tokens[0];
        identifier = identifier.replace("{", "").replace("(", "").replace(":", "");
        return identifier;
    }

    def run_agent(repo: any) -> dict {
        if repo.status != "mapped" {
            repo.status = "error";
            repo.error = "Repository must be mapped before analysis";
            return {"success" : False , "error" : repo.error };
        }
        if not repo.local_path {
            repo.status = "error";
            repo.error = "Local repository path missing";
            return {"success" : False , "error" : repo.error };
        }
        repo.status = "analyzing";
        try {
            self.analysis_results = self.analyze_repository(repo.local_path);
        } except Exception as e {
            repo.status = "error";
            repo.error = "Analysis failed: " + str(e);
            return {"success" : False , "error" : repo.error };
        }
        if not self.analysis_results {
            repo.status = "error";
            repo.error = "No analysable files discovered";
            return {"success" : False , "error" : repo.error };
        }
        files_report = [];
        for entry in self.analysis_results {
            files_report.append(entry.get("path", ""));
        }
        repo.status = "analyzed";
        return {"success" : True , "files" : files_report };
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
        if repo.status != "mapped" {
            repo.status = "error";
            repo.error = "Repository must be mapped before analysis";
            report {"error" : repo.error } ;
            disengage;
        }
        if not repo.local_path {
            repo.status = "error";
            repo.error = "Local repository path missing";
            report {"error" : repo.error } ;
            disengage;
        }
        repo.status = "analyzing";
        try {
            self.analysis_results = self.analyze_repository(repo.local_path);
        } except Exception as e {
            repo.status = "error";
            repo.error = "Analysis failed: " + str(e);
            report {"error" : repo.error } ;
            disengage;
        }
        if not self.analysis_results {
            repo.status = "error";
            repo.error = "No analysable files discovered";
            report {"error" : repo.error } ;
            disengage;
        }
        files_report = [];
        for entry in self.analysis_results {
            files_report.append(entry.get("path", ""));
        }
        repo.status = "analyzed";
        report {"success" : True , "files" : files_report } ;
    }
}


sem CodeAnalyzer. analyze_repository= """
Traverse the repository and extract useful structural information from source
files. Focus on Python and Jac code. Capture functions, classes, nodes, and
walkers so downstream agents can generate documentation.
""";
