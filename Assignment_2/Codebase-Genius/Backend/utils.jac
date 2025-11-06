import os;
import uuid;


def is_valid_github_url(url: str) -> bool {
    return url.startswith("https://github.com/") and len(url.split("/")) >= 5;
}


def extract_repo_name(url: str) -> str {
    parts = url.rstrip("/").split("/");
    if len(parts) >= 2 {
        return parts[len(parts) - 2] + "/" + parts[len(parts) - 1];
    }
    return parts[len(parts) - 1];
}


def ensure_directory(path: str) -> str {
    if not os.path.exists(path) {
        os.makedirs(path);
    }
    return path;
}


def generate_token()  -> str {
    return uuid.uuid4().hex;
}
