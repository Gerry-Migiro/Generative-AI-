# Codebase Genius

An AI-powered, multi-agent system that automatically generates documentation for software repositories.

## Overview

Codebase Genius analyzes GitHub repositories and generates comprehensive markdown documentation including project overviews, installation guides, and API references.

## Architecture

The system uses three main agents:

1. **Repo Mapper** - Clones repositories and creates file trees
2. **Code Analyzer** - Analyzes Python and Jac files to extract functions and classes
3. **Doc Genie** - Generates final markdown documentation

## Project Structure

```
Assignment_2/Codebase-Genius/
├── .gitignore              # Git ignore rules
├── README.md               # This file
├── Backend/                # Main backend implementation
│   ├── main.jac           # Main entry point
│   ├── utils.jac          # Utility functions
│   ├── agents/            # Multi-agent components
│   │   ├── repo_mapper.jac
│   │   ├── code_analyzer.jac
│   │   └── doc_genie.jac
│   ├── requirements.txt   # Backend dependencies
│   └── .env.example       # Environment template
└── Frontend/              # Web interface
    ├── app.py            # Streamlit frontend
    └── requirements.txt  # Frontend dependencies
```

## Setup Instructions

### Prerequisites

- Python 3.8+
- Git
- JacLang (`pip install jaclang`)

### Installation

1. Navigate to the backend directory:

```bash
cd Assignment_2/Codebase-Genius/Backend
```

2. Install backend dependencies:

```bash
pip install -r requirements.txt
```

3. Set up environment variables (at project root):

```bash
cd ..
cp .env.example .env
# Edit .env and add GEMINI_API_KEY or OPENAI_API_KEY
```

### Running the System

1. Start the backend server:

```bash
cd Backend
jac serve main.jac
```

2. Start the frontend (in a new terminal):

```bash
cd Frontend
pip install -r requirements.txt
streamlit run app.py
```

3. Open your browser to `http://localhost:8501`

## Usage

### Web Interface

1. Open the Streamlit frontend
2. Enter a GitHub repository URL
3. Click "Generate Documentation"
4. Check the `outputs/` folder for generated documentation

### API Usage

The backend follows the byLLM Task Manager pattern and provides the following endpoints:

```bash
# Generate documentation
curl -X POST "http://localhost:8000/walker/codebase_genius" \
  -H "Content-Type: application/json" \
  -d '{"repo_url": "https://github.com/username/repository"}'

# List repositories
curl -X POST "http://localhost:8000/walker/repositories" \
  -H "Content-Type: application/json" \
  -d '{}'

# Health check
curl -X POST "http://localhost:8000/walker/health" \
  -H "Content-Type: application/json" \
  -d '{}'
```

**API Endpoints:**
- `POST /walker/codebase_genius` – Generate documentation for a repository
- `POST /walker/repositories` – List all processed repositories  
- `POST /walker/health` – Health check

## Output

Generated documentation is saved to `outputs/{repo_name}/docs.md` (under project root) and includes:

- Project overview
- Installation instructions
- Code structure analysis
- API reference with functions and classes

## Features

- **Multi-language support** (Python, Jac)
- **Automatic code analysis** with AST parsing
- **README summarization**
- **Web-based interface**
- **Structured markdown output**

## Backend Structure

- `main.jac` – Main entry point with walkers
- `utils.jac` – Utility functions  
- `agents/` – Multi-agent components (repo_mapper, code_analyzer, doc_genie)

## Notes

- Public GitHub repositories only
- Optimized for Python and Jac projects
- Generated files are saved in `temp_repos/` and `outputs/` under project root
- Environment variables are loaded from `Codebase-Genius/.env`
- The system follows the multi-agent architecture pattern from the byLLM reference implementation
- Documentation output written to `outputs/{owner_repo}/docs.md` under project root
