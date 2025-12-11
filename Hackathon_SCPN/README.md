# Smart Career Path Navigator

An AI-powered career guidance platform built with **Jaseci Programming Language** (Jac) that provides personalized career recommendations using **Object-Spatial Programming (OSP)**, **Multi-Agent AI**, and **Jac Client**.

## 🎯 Project Overview

This platform helps users navigate their career paths by:
- Analyzing skills and identifying gaps using OSP graph traversals
- Providing AI-powered career strategy recommendations via multi-agent systems
- Offering personalized learning roadmaps based on market trends
- Matching users to roles using graph-based scoring algorithms

## 🏗️ Architecture

### OSP Graph Structure

The platform leverages **Object-Spatial Programming** with the following graph model:

**Nodes:**
- `User` - User profiles with skills, interests, and career goals
- `Role` - Job roles with salary ranges and descriptions
- `Skill` - Technical skills and competencies
- `Course` - Learning resources
- `JobPosting` - Live job opportunities

**Edges:**
- `UserSkill(level: int)` - User's proficiency in skills
- `RequiresSkill(importance: int)` - Role requirements with 1-10 importance scoring
- `PrerequisiteOf(difficulty_gap: int)` - Skill learning paths

### Multi-Agent System

**Three specialized AI agents** orchestrate career guidance:

1. **Career Strategy Analyzer** (`analyze_career_strategy`)
   - Identifies user strengths and skill gaps
   - Analyzes fit for target roles
   - Provides strategic recommendations

2. **Market Research Analyzer** (`analyze_market`)
   - Researches current job market trends
   - Identifies in-demand skills
   - Provides salary and demand insights

3. **Learning Path Designer** (`create_learning_plan`)
   - Creates personalized learning roadmaps
   - Generates week-by-week study plans
   - Recommends resources based on skill gaps

**Agent Flow:**
```
User Request → generate_roadmap → calculate_role_match (OSP) 
           → analyze_career_strategy → analyze_market → create_learning_plan
```

### OSP Graph Reasoning

**Walker: `calculate_role_match`**

Demonstrates non-trivial OSP graph traversal:

```jac
# Traverse Role->RequiresSkill->Skill edges with importance scoring
for skill_edge in [here->:RequiresSkill:->] {
    let skill_node = [here->:RequiresSkill:->(`?Skill)][-1];
    # Calculate weighted match score based on edge importance
    matched_importance += edge.importance;
}
match_score = (matched_importance / total_importance) * 100;
```

**Key OSP Features:**
- Edge-based filtering and scoring
- Graph traversal for role-skill relationships
- Weighted importance calculations
- Prerequisite chain analysis

### byLLM Integration

**Generative Uses:**
- Career strategies and recommendations
- Market analysis summaries
- Personalized learning plans

**Analytical Uses:**
- Resume parsing and skill extraction (`resume_parser`)
- Text classification and validation
- Content scoring

**Example:**
```jac
def analyze_career_strategy(
    user_skills: list, target_role: str, user_interests: list, context: str
) -> str by llm(method="Reason");
```

### Jac Client Integration

Frontend uses **Spawn()** for all backend calls:

```jac
// Profile page - spawning walkers
let res = await root spawn get_profile();
await root spawn add_skill(skill_name=newSkill);

// Career path - generating roadmap
let res = await root spawn generate_roadmap(target_role=role);

// Jobs page - fetching opportunities
let res = await root spawn fetch_jobs(role_filter=role);
```

All 7 pages use React-style components with Jac Client for seamless backend integration.

## 🎓 Hackathon Requirements Proof

### ✅ Multi-Agent System
**Location:** [app.jac](app.jac#L48-67)
- Agent 1: `analyze_career_strategy` (strategy & gaps)
- Agent 2: `analyze_market` (market trends)
- Agent 3: `create_learning_plan` (learning roadmap)
- **Agent Flow:** User → generate_roadmap → OSP → Agent 1 → Agent 2 → Agent 3

### ✅ OSP Graph Usage
**Location:** [app.jac](app.jac#L77-160)
- **Edges:** `RequiresSkill(importance)`, `PrerequisiteOf(difficulty_gap)`, `UserSkill(level)`
- **Walker:** `calculate_role_match` - Traverses Role→RequiresSkill→Skill with weighted scoring
- **Advantage:** Single graph traversal vs multiple REST calls
- **Example:** `[role->:RequiresSkill:importance>=8:->]`

### ✅ byLLM Integration
**Location:** [app.jac](app.jac#L48-74)
- **Generative:** Career strategies, market analysis, learning plans (3 agents)
- **Analytical:** `resume_parser` - Extracts skills from resume text
- **Model:** gemini/gemini-2.5-flash

### ✅ Jac Client
**Location:** [frontend/pages/](frontend/pages/)
- **16 Spawn() calls** across 7 pages
- Examples: `root spawn get_profile()`, `root spawn generate_roadmap(target_role=role)`
- All frontend-backend calls use Spawn() (no REST APIs)

## 🚀 Setup & Installation

### Prerequisites

- Node.js (v16+)
- Jac CLI
- Python 3.10+

### Installation

1. **Clone the repository:**
```bash
git clone <your-repo-url>
cd todo-app
```

2. **Install dependencies:**
```bash
npm install
```

3. **Set up environment:**
```bash
# Add your LLM API key if needed
export GEMINI_API_KEY="your-key-here"
```

### Running the Application

**Start the Jac server:**
```bash
jac serve app.jac
```

The application will be available at `http://localhost:8000`

## 📊 Features

### 1. Profile Management
- Resume upload and skill extraction (AI-powered)
- Manual skill addition/deletion
- Interest and goal tracking

### 2. Career Path Generation
- AI-powered roadmap creation
- OSP graph-based role matching (match score %)
- Multi-agent analysis (strategy + market + learning plan)

### 3. Job Discovery
- Live job fetching from external APIs
- Role-based filtering
- Match scoring

### 4. Learning Resources
- Curated course recommendations
- Skill-based learning paths

## 🧪 Testing

**Check for syntax errors:**
```bash
jac check app.jac
```

**Run seed data:**
The database automatically seeds on first run with:
- 5 roles (Software Developer, Data Scientist, DevOps, Product Manager, UX Designer)
- 10 skills with OSP relationships
- 10+ courses
- Role-Skill graphs with importance weights

## 📈 OSP Graph Advantages

Unlike traditional REST APIs, our OSP implementation provides:

1. **Weighted Scoring:** Edge importance values enable nuanced role matching
2. **Graph Traversal:** Multi-hop reasoning (User→Skill→Role→Prerequisites)
3. **Dynamic Relationships:** Skill prerequisites and role requirements as first-class graph entities
4. **Efficient Queries:** Direct graph navigation vs multiple API calls

## 🎓 Hackathon Requirements Met

✅ **Multi-Agent Design:** 3 specialized agents with documented interaction flow  
✅ **OSP Graph Usage:** Named edges, traversals, scoring algorithms  
✅ **byLLM Integration:** Generative (roadmaps) + analytical (resume parsing)  
✅ **Jac Client:** Spawn() calls throughout frontend  
✅ **Seed Data:** Comprehensive test data with realistic examples

## 📝 Agent Interaction Diagram

```
                    User Input
                        |
                        v
               generate_roadmap Walker
                        |
                        +----> calculate_role_match (OSP)
                        |       - Graph traversal
                        |       - Edge scoring
                        |       - Match calculation
                        |
                        +----> analyze_career_strategy (Agent 1)
                        |       - Identify strengths
                        |       - Find skill gaps
                        |
                        +----> analyze_market (Agent 2)
                        |       - Market demand
                        |       - Salary ranges
                        |
                        +----> create_learning_plan (Agent 3)
                                - Week-by-week plan
                                - Resource recommendations
                                |
                                v
                        Combined Response
```

## 🛠️ Technology Stack

- **Backend:** Jaseci/Jac Programming Language
- **Frontend:** Jac Client (React-style components)
- **AI/LLM:** byLLM with Gemini Flash 2.5
- **Graph Model:** OSP with typed nodes and edges
- **API Integration:** Remotive Jobs API

## � Project Stats

- **Backend:** 830 lines (app.jac)
- **Frontend:** 1,901 lines (7 pages)
- **Walkers:** 11 (9 exposed via API)
- **Spawn Calls:** 16 across frontend
- **OSP Edges:** 3 types with attributes
- **AI Agents:** 3 (byLLM-powered)

## 📚 Key Files

- [`app.jac`](app.jac) - Main backend (OSP graph, walkers, multi-agent system)
- [`frontend/pages/`](frontend/pages/) - Jac Client components (Dashboard, Profile, Career, Jobs, Courses)


## 🧪 Testing

```bash
# Check for errors
jac check app.jac

# Build application  
jac build app.jac

# Start server
jac serve app.jac
```

Access at `http://localhost:8000`



**Built for AI Hackathon 2025** | Deadline: Dec 15, 2025  
[Discord](https://discord.gg/jSQP7rjA) | [Jaseci GitHub](https://github.com/jaseci-labs/jaseci)
