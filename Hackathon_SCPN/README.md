# Smart Career Path Navigator

> AI-powered career guidance platform built with Jaseci Programming Language (Project 4 - AI Hackathon)

## Overview

Smart Career Path Navigator provides personalized career guidance by linking users' skills and interests to roles, courses, and live job market trends. The platform uses an Object-Spatial Programming (OSP) graph to model user profiles, target roles, and learning resources, with byLLM agents performing gap analysis and generating personalized learning roadmaps.

## Key Features

- **AI-Powered Career Analysis**: Multi-agent system analyzes career strategies, market trends, and learning paths
- **Resume Parsing**: Automatically extract skills from resume text using AI
- **Skill Gap Analysis**: Identify missing skills for target roles
- **Learning Roadmap Generation**: Personalized weekly learning plans
- **Live Job Market Data**: Real-time job listings from Remotive API
- **Interactive Dashboard**: Visualize career progress and recommendations
- **Graph-Based Profile**: OSP graph stores user skills, interests, and goals

## Jaseci Features Demonstrated

### 1. **Object-Spatial Programming (OSP)**
- **Named Node Types**: `User`, `Role`, `Skill`, `Course`, `JobPosting`
- **Named Edge Types**: `UserSkill` (with `level` property)
- **Graph Traversals**: 
  - `[here->:UserSkill:->]` - Get user's skills
  - `[here-->](?Role)` - Query available roles
  - `[-->](?Course)` - Fetch courses
- **Graph-Based Reasoning**: Profile management, skill gap analysis, career path recommendations

### 2. **byLLM Integration** (Multi-Agent System)

#### Agent 1: Career Strategy Analyzer
- **Type**: Generative & Analytical
- **Function**: `analyze_career_strategy(user_skills, target_role, user_interests, context)`
- **Purpose**: Identifies strengths and skill gaps

#### Agent 2: Market Research Analyzer
- **Type**: Generative
- **Function**: `analyze_market(role_title, context)`
- **Purpose**: Researches job market trends and salary ranges

#### Agent 3: Learning Path Designer
- **Type**: Generative
- **Function**: `create_learning_plan(missing_skills, timeline, context)`
- **Purpose**: Creates personalized learning roadmaps

#### Agent 4: Resume Parser
- **Type**: Analytical
- **Function**: `resume_parser(resume_text)`
- **Purpose**: Extracts technical skills from resume text

**Agent Flow**: 
```
User Request → generate_roadmap → analyze_career_strategy → analyze_market → create_learning_plan
User Resume → parse_resume → resume_parser → add skills to graph
```

### 3. **Jac Client (Frontend)**
- React-style components using Jac Client
- All backend communication via `root spawn walker_name()` (no direct API calls)
- Pages: Dashboard, Profile, CareerPath, Jobs, Courses
- Real-time updates with Spawn() calls

## Technical Architecture

### Backend (app.jac)
- **Nodes**: User, Role, Skill, Course, JobPosting
- **Edges**: UserSkill (with level property)
- **Walkers**: 
  - `seed_database` - Initialize demo data
  - `get_profile` / `update_profile` - User management
  - `add_skill` / `delete_skill` - Skills management
  - `parse_resume` - AI-powered resume parsing
  - `generate_roadmap` - Multi-agent career analysis
  - `fetch_jobs` - Live job data from Remotive API
  - `get_all_roles` - Role listings
  - `get_recommended_courses` - Course suggestions

### Frontend (Jac Client)
- **Components**: Navbar
- **Pages**: Dashboard, Profile, CareerPath, Jobs, Courses, Login, Signup
- **Styling**: Dark theme with professional UI (globals.css)

### External Integrations
- **Remotive API**: Real-time remote job listings
- **Gemini 2.5 Flash**: LLM for byLLM agents

## Installation & Setup

### Prerequisites
- Python 3.10+
- Node.js 18+
- Jac CLI installed

### Install Dependencies

```bash
# Install Node modules
npm install

# Install Python packages (if needed)
pip install jaclang
```

### Environment Setup

Create a `.env` file with your API keys:
```bash
# Gemini API Key (for byLLM)
GEMINI_API_KEY=your_gemini_api_key_here
```

### Run the Application

```bash
jac serve app.jac
```

The server will start on `http://localhost:8000`

## Usage

### 1. Create Profile
- Navigate to Profile page
- Enter your name, interests, and career goals
- Add your skills manually or paste resume for AI extraction

### 2. Generate Career Roadmap
- Go to CareerPath page
- Select target role (e.g., "Software Developer")
- Click "Generate Roadmap"
- View AI-generated career strategy, market analysis, and learning plan

### 3. Browse Jobs
- Navigate to Jobs page
- Jobs are automatically fetched based on your target role
- Filter by specific roles

### 4. Explore Courses
- Visit Courses page to see recommended learning resources

## Demo Data

The application includes seed data:
- 5 career roles (Software Developer, Data Scientist, Product Manager, DevOps Engineer, UX Designer)
- 10 courses (Python, Data Science, Web Dev, Machine Learning, AWS, React, SQL, Product Management, DevOps, UX)
- 15 job postings (fallback data if API fails)

## Hackathon Compliance

✅ **Multi-Agent Design**: 4 specialized byLLM agents with distinct responsibilities
✅ **OSP Graph Usage**: Named nodes/edges with graph traversals and reasoning
✅ **byLLM Integration**: Generative (roadmap, market analysis) + Analytical (skill extraction, gap analysis)
✅ **Jac Client**: Frontend uses Spawn() for all backend communication
✅ **Seed Data**: Realistic demo data for roles, skills, courses, jobs

## Project Structure

```
Hackathon_SCPN/
├── app.jac                 # Backend (Nodes, Edges, Walkers, Agents)
├── frontend/
│   ├── components/
│   │   └── Navbar.jac
│   ├── pages/
│   │   ├── Dashboard.jac
│   │   ├── Profile.jac
│   │   ├── CareerPath.jac
│   │   ├── Jobs.jac
│   │   ├── Courses.jac
│   │   ├── LoginPage.jac
│   │   └── SignupPage.jac
│   └── globals.css
├── package.json
├── vite.config.js
└── README.md
```

## Technologies Used

- **Jaseci Programming Language** (Jac)
- **Object-Spatial Programming** (OSP)
- **byLLM** (Gemini 2.5 Flash)
- **Jac Client** (React-style frontend)
- **Remotive API** (Job data)
- **Vite** (Build tool)

## Known Limitations

- Gemini API has rate limits on free tier
- Resume parser requires well-formatted resume text
- Job data depends on Remotive API availability

## Future Enhancements

- Add skill proficiency tracking
- Implement course progress tracking
- Add notifications for new opportunities
- Enhance graph visualization
- Support for multiple resume formats (PDF, DOCX)

## Team

**Developer**: Gerson  
**Project**: AI Hackathon - Project 4 (Smart Career Path Navigator)  
**Submission Date**: December 15, 2025

## License

This project is created for the AI Hackathon educational program.

---

**Discord**: [Join the community](https://discord.gg/jSQP7rjA)  
**GitHub**: [Jaseci Labs](https://github.com/jaseci-labs/jaseci)
