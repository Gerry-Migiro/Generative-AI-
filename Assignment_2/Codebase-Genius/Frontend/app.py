import streamlit as st
import requests
import os

st.set_page_config(
    page_title="Codebase Genius",
    page_icon="📚",
    layout="wide"
)

st.markdown("""
    <style>
        .main > div {
            max-width: 1200px;
            padding: 2rem;
        }
        
        .status-success {
            color: #28a745;
            font-weight: bold;
        }
        
        .status-error {
            color: #dc3545;
            font-weight: bold;
        }
        
        .status-processing {
            color: #ffc107;
            font-weight: bold;
        }
        
        .repo-card {
            border: 1px solid #2c2f36;
            border-radius: 8px;
            padding: 1rem;
            margin: 0.5rem 0;
            background-color: #1e1f29;
            color: #f5f6f8;
        }

        .repo-card a {
            color: #4da3ff;
            text-decoration: none;
        }

        .repo-card a:hover {
            text-decoration: underline;
        }
    </style>
""", unsafe_allow_html=True)

# Configuration Constants
BACKEND_START_COMMAND = "cd Backend && jac serve main.jac"
BASE_URL = "http://localhost:8000"

# API Endpoints
PROCESS_ENDPOINT = f"{BASE_URL}/walker/codebase_genius"
LIST_REPOS_ENDPOINT = f"{BASE_URL}/walker/repositories"
HEALTH_ENDPOINT = f"{BASE_URL}/walker/health"


def unwrap_reports(payload):
    """Jac walker responses wrap data in a reports list; extract the first entry."""
    if isinstance(payload, dict):
        reports = payload.get("reports")
        if isinstance(reports, list) and reports:
            first = reports[0]
            if isinstance(first, dict):
                return first
            if isinstance(first, list):
                return first
        return payload
    return payload


def show_backend_offline_error():
    st.error("❌ Cannot connect to the server. Make sure the Jac server is running:")
    st.code(BACKEND_START_COMMAND)


def post_backend(endpoint, payload=None, timeout=15, show_offline_message=True):
    try:
        return requests.post(endpoint, json=payload or {}, timeout=timeout)
    except requests.exceptions.ConnectionError:
        if show_offline_message:
            show_backend_offline_error()
    except Exception as exc:
        st.error(f"An error occurred: {exc}")
    return None


def parse_backend_json(response):
    try:
        return response.json()
    except ValueError:
        st.error("Invalid response from server")
        return None


def make_backend_request(endpoint, payload=None, timeout=15, show_offline_message=True):
    """Unified function to make backend requests and parse JSON response"""
    response = post_backend(endpoint, payload, timeout, show_offline_message)
    if response is None:
        return None
    elif response.status_code != 200:
        st.error(f"Server error: {response.status_code}")
        return None
    else:
        return parse_backend_json(response)


def display_documentation_result(result):
    st.success("Documentation generation started!")
    col1, col2 = st.columns(2)
    with col1:
        st.info(f"**Repository:** {result.get('repository', 'Unknown')}")
    with col2:
        st.info(f"**Status:** {result.get('status', 'Unknown')}")

    if not result.get('success'):
        return

    st.success("✅ Documentation generated successfully!")
    st.info(f"📁 **Output Path:** `{result.get('documentation_path', 'Unknown')}`")

    if result.get('readme_summary'):
        st.markdown("---")
        st.markdown("### 📝 README Summary")
        st.write(result['readme_summary'])

    doc_path = result.get('documentation_path')
    if doc_path:
        st.markdown("---")
        st.markdown("### 📥 Documentation Output")
        st.markdown(f"Saved at: `{doc_path}`")
        if os.path.exists(doc_path):
            with open(doc_path, 'r', encoding='utf-8') as doc_file:
                doc_content = doc_file.read()
            st.markdown("---")
            st.markdown("### 📄 Documentation Preview")
            st.markdown(doc_content)
        else:
            st.warning("Documentation file not found yet. Please check the outputs folder once the process finishes.")


def render_repository_card(repo):
    st.markdown(f"""
    <div class="repo-card">
        <h4>📁 {repo.get('name', 'Unknown')}</h4>
        <p><strong>URL:</strong> <a href="{repo.get('url', '#')}" target="_blank">{repo.get('url', 'Unknown')}</a></p>
        <p><strong>Status:</strong> <span class="status-{repo.get('status', 'unknown').lower()}">{repo.get('status', 'Unknown').title()}</span></p>
        <p><strong>Docs:</strong> {repo.get('documentation_path') or 'Not generated'}</p>
        <p><strong>Summary:</strong> {repo.get('readme_summary', 'N/A')}</p>
    </div>
    """, unsafe_allow_html=True)


def render_feature_list():
    """Render the features section to avoid duplication"""
    st.markdown("### ✨ Features")
    col1, col2 = st.columns(2)
    with col1:
        st.markdown("""
        - **Multi-language support** (Python, Jac)
        - **Automatic code analysis**
        - **Function and class extraction**
        - **README summarization**
        """)
    with col2:
        st.markdown("""
        - **Structured documentation**
        - **Installation guides**
        - **API reference generation**
        - **Usage examples**
        """)


def render_sidebar_info():
    """Render sidebar information to keep main code cleaner"""
    st.markdown("### 📚 About")
    st.markdown("""
    **Codebase Genius** is an AI-powered system that automatically generates 
    comprehensive documentation for software repositories.

    **Supported Languages:**
    - Python
    - Jac
    - Generic file analysis

    **Generated Documentation:**
    - Project overview
    - Installation instructions
    - Code structure analysis
    - API reference
    - Usage examples
    """)

    st.markdown("---")
    st.markdown("### 🚀 Quick Start")
    st.markdown("""
    1. Start the backend server: `cd Backend && jac serve main.jac`
    2. Enter a GitHub repository URL
    3. Click "Generate Documentation"
    4. Check the outputs folder at the project root for results
    """)


st.title("📚 Codebase Genius")
st.markdown("*AI-powered automatic code documentation generator*")

tab1, tab2 = st.tabs(["🚀 Generate Documentation", "📋 Repository History"])

with tab1:
    st.header("Generate Documentation")

    with st.form("repo_form"):
        repo_url = st.text_input(
            "GitHub Repository URL",
            placeholder="https://github.com/username/repository",
            help="Enter a public GitHub repository URL"
        )
        submitted = st.form_submit_button("🔄 Generate Documentation")

        if submitted:
            if not repo_url.strip():
                st.error("Please enter a GitHub repository URL")
            elif not (repo_url.startswith("https://github.com/") or repo_url.startswith("http://github.com/")):
                st.error("Please enter a valid GitHub repository URL (must start with https://github.com/)")
            else:
                repo_url = repo_url.strip()
                with st.spinner("Starting documentation generation..."):
                    payload = {"repo_url": repo_url}
                    raw_result = make_backend_request(PROCESS_ENDPOINT, payload)
                    
                    if raw_result is not None:
                        result = unwrap_reports(raw_result) or {}
                        if isinstance(result, dict) and "error" in result:
                            st.error(f"Error: {result['error']}")
                        else:
                            display_documentation_result(result)

    st.markdown("---")
    st.markdown("### 📖 How to Use")
    st.markdown("""
    1. **Enter a GitHub URL** - Paste the URL of a public GitHub repository
    2. **Click Generate** - The system will clone and analyze the repository
    3. **Wait for completion** - The process may take a few minutes depending on repository size
    4. **Download documentation** - Find the generated markdown documentation in the outputs folder
    """)

    st.markdown("### ✨ Features")
    col1, col2 = st.columns(2)
    with col1:
        st.markdown("""
        - **Multi-language support** (Python, Jac)
        - **Automatic code analysis**
        - **Function and class extraction**
        - **README summarization**
        """)
    with col2:
        st.markdown("""
        - **Structured documentation**
        - **Installation guides**
        - **API reference generation**
        - **Usage examples**
        """)

with tab2:
    st.header("📋 Repository History")

    col1, col2 = st.columns([1, 4])
    with col1:
        if st.button("🔄 Refresh"):
            st.rerun()

    with st.spinner("Loading repositories..."):
        raw_result = make_backend_request(LIST_REPOS_ENDPOINT)
        
        if raw_result is not None:
            repos_payload = unwrap_reports(raw_result)
            repositories = []
            if isinstance(repos_payload, list):
                repositories = repos_payload
            elif isinstance(repos_payload, dict):
                repositories = repos_payload.get("items", [])

            if repositories:
                st.success(f"Found {len(repositories)} processed repositories")
                for repo in repositories:
                    with st.container():
                        render_repository_card(repo)
            else:
                st.info("No repositories have been processed yet.")

with st.sidebar:
    st.markdown("### 🔧 Server Status")

    health_response = post_backend(HEALTH_ENDPOINT, timeout=2, show_offline_message=False)
    if health_response is None:
        st.error("❌ Server Offline")
        st.markdown("**Start the server:**")
        st.code(BACKEND_START_COMMAND)
    elif health_response.status_code == 200:
        st.success("✅ Server Online")
    else:
        st.error("❌ Server Error")

    st.markdown("---")
    render_sidebar_info()
