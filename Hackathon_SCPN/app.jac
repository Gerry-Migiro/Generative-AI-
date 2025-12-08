# Backend Code
import from byllm.lib { Model }
import from json { loads, dumps }

glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=False);

# --- Nodes ---

node User {
    has name: str = "";
    has interests: list = [];
    has goals: list = [];
    has target_role: str = "";
    has last_gaps_analysis: str = "[]";
    has last_roadmap_plan: str = "[]";
    has last_strategy: str = "[]";
    has last_market: str = "[]";
    has last_jobs: str = "[]";
    has jobs_role_filter: str = "";
}

node Role {
    has title: str = "";
    has salary_range: str = "N/A";
    has description: str = "";
}

node Skill {
    has name: str = "";
}

node Course {
    has title: str = "";
    has url: str = "";
    has duration: str = "";
}

node JobPosting {
    has title: str = "";
    has company: str = "";
    has posted_date: str = "";
}

# --- Edges ---

edge UserSkill {
    has level: int = 0;
}

edge Requires {
    has proficiency: int = 50;
}

edge Teaches {
    has proficiency_gain: int = 10;
}

# --- Agents ---
# Multi-Agent System: Career Advisor with 4 specialized agents
# Agent Flow: User Request → generate_roadmap → analyze_career_strategy → analyze_market → create_learning_plan
#             User Request → fetch_jobs → suggest_jobs

# Agent 1: Career Strategy Analyzer - Identifies strengths and skill gaps
def analyze_career_strategy(user_skills: list, target_role: str, user_interests: list, context: str) -> str by llm(method="Reason");

# Agent 2: Market Research Analyzer - Researches job market trends
def analyze_market(role_title: str, context: str) -> str by llm(method="Reason");

# Agent 3: Learning Path Designer - Creates personalized learning roadmap
def create_learning_plan(missing_skills: list, timeline: str, context: str) -> str by llm(method="Reason");

# Agent 4: Job Matcher - Matches user profile to job opportunities
def suggest_jobs(profile_skills: list, profile_interests: list, profile_goals: list, role_filter: str, context: str) -> str by llm(method="Reason");

"""Extract technical skills from resume text. Return only concrete tools, languages, frameworks, and technologies as nouns. Skip job titles, company names, soft skills, general and unecessary descriptions.""" 
def resume_parser(resume_text: str) -> list[str] by llm(method="Reason");

# Agent 6: External Job Fetcher - Simulates fetching job postings from external APIs
def external_job_fetcher(keywords: str, location: str, limit: int) -> dict by llm(method="Reason", context="Generate realistic job postings matching the keywords and location. Return JSON with 'jobs' array containing title, company, location, description, posted_date, url fields.");

# --- Walkers ---

walker seed_database {
    can seed with `root entry {
        # Check if already seeded
        let existing_roles = [here -->](`?Role);
        if len(existing_roles) > 0 {
            print("Database already seeded");
            return;
        }

        print("Seeding database...");

        # Create Roles
        here ++> Role(title="Software Developer", salary_range="$80k - $150k", description="Builds software applications");
        here ++> Role(title="Data Scientist", salary_range="$100k - $180k", description="Analyzes complex data");
        here ++> Role(title="Product Manager", salary_range="$90k - $160k", description="Oversees product development");
        here ++> Role(title="DevOps Engineer", salary_range="$90k - $160k", description="Manages infrastructure and deployments");
        here ++> Role(title="UX Designer", salary_range="$70k - $130k", description="Designs user experiences");

        # Create Courses
        here ++> Course(title="Python Programming Masterclass", url="https://udemy.com/python", duration="40 hours");
        here ++> Course(title="Data Science Bootcamp", url="https://coursera.org/data-science", duration="3 months");
        here ++> Course(title="Web Development Complete", url="https://udemy.com/web-dev", duration="60 hours");
        here ++> Course(title="Machine Learning Specialization", url="https://coursera.org/ml", duration="4 months");
        here ++> Course(title="AWS Cloud Practitioner", url="https://aws.amazon.com/training", duration="20 hours");

        print("Database seeded successfully");
    }
}

walker get_all_roles {
    can return_roles with `root entry {
        let roles = [here -->](`?Role);
        if len(roles) == 0 {
            # Auto-seed if no roles exist
            here spawn seed_database();
            roles = [here -->](`?Role);
        }

        let role_list = [];
        for r in roles {
            role_list.append({"title": r.title, "description": r.description, "salary": r.salary_range});
        }
        report role_list;
    }
}

walker get_all_courses {
    can return_courses with `root entry {
        let courses = [here -->](`?Course);
        let course_list = [];
        for c in courses {
            course_list.append({"title": c.title, "url": c.url, "duration": c.duration});
        }
        report course_list;
    }
}

# Resume Parsing Walker: Extracts skills, experience, education from resume text
walker parse_resume {
    has resume_text: str;
    
    can extract_info with `root entry {
        visit [-->](`?User) else {
            # Auto-create user if doesn't exist
            here ++> User(name="", interests=[], goals=[], target_role="");
            visit [-->](`?User);
        }
    }
    
    can parse_and_update with User entry {
        # Use AI agent to extract skills from resume text
        let skill_list = resume_parser(resume_text=self.resume_text);
        
        # Get current skills to avoid duplicates
        let current_skills = [];
        for s in [here ->:UserSkill:->] {
            current_skills.append(s.name);
        }
        
        # Add new skills from resume
        let added_skills = [];
        let skipped_skills = [];
        
        for skill_name in skill_list {
            if skill_name not in current_skills {
                # Create new skill and connect (simple approach)
                here +>:UserSkill(level=50):+> Skill(name=skill_name);
                added_skills.append(skill_name);
            } else {
                skipped_skills.append(skill_name);
            }
        }
        
        # Return structured resume data with update info
        report {
            "skills": skill_list,
            "added_skills": added_skills,
            "skipped_skills": skipped_skills,
            "total_skills": len(current_skills) + len(added_skills)
        };
    }
}

# External Job Fetching Walker: Fetches real job postings from external APIs
walker fetch_external_jobs {
    has keywords: str;
    has location: str = "remote";
    has limit: int = 10;
    
    can fetch_jobs with `root entry {
        # Use AI agent to simulate job API fetching
        let job_results = external_job_fetcher(
            keywords=keywords,
            location=location,
            limit=limit
        );
        
        # Store job postings in graph
        for job_data in job_results["jobs"] {
            let job_node = JobPosting(
                title=job_data["title"],
                company=job_data["company"],
                location=job_data["location"],
                description=job_data["description"],
                posted_date=job_data["posted_date"],
                url=job_data["url"]
            );
            here ++> job_node;
        }
        
        report {"jobs_fetched": job_results["jobs"].length, "jobs": job_results["jobs"]};
    }
}

# OSP Skill Matching Walker: Calculate similarity between user skills and target role
walker calculate_skill_match {
    has target_skills: list;
    has match_score: float = 0.0;
    
    can match with User entry {
        let user_skills = [];
        for s in [here ->:UserSkill:->] {
            user_skills.append(s.name);
        }
        
        # Jaccard similarity: intersection / union
        let user_set = set(user_skills);
        let target_set = set(self.target_skills);
        let intersection = user_set.intersection(target_set);
        let union = user_set.union(target_set);
        
        if len(union) > 0 {
            self.match_score = (len(intersection) / len(union)) * 100;
        }
        
        report {
            "match_percentage": self.match_score,
            "user_skills": user_skills,
            "target_skills": self.target_skills,
            "matched_skills": list(intersection),
            "missing_skills": list(target_set.difference(user_set))
        };
    }
}

walker get_profile {
    can get_profile with `root entry {
        visit [-->](`?User) else {
            # Auto-create user if doesn't exist
            here ++> User(name="", interests=[], goals=[], target_role="");
            visit [-->](`?User);
        }
    }
    can return_profile with User entry {
        let skills = [];
        for s in [here ->:UserSkill:->] {
            skills.append(s.name);
        }
        report {
            "name": here.name,
            "interests": here.interests,
            "goals": here.goals,
            "skills": skills,
            "target_role": here.target_role,
            "last_gaps_analysis": here.last_gaps_analysis,
            "last_roadmap_plan": here.last_roadmap_plan,
            "last_strategy": here.last_strategy,
            "last_market": here.last_market,
            "last_jobs": here.last_jobs,
            "jobs_role_filter": here.jobs_role_filter
        };
    }
}

walker update_profile {
    has name: any = None;
    has interests: any = None;
    has goals: any = None;
    has target_role: any = None;
    can start with `root entry {
        visit [-->](`?User) else {
            # Auto-create user if doesn't exist
            here ++> User(
                name=self.name if self.name != None else "", 
                interests=self.interests if self.interests != None else [], 
                goals=self.goals if self.goals != None else [], 
                target_role=self.target_role if self.target_role != None else ""
            );
            visit [-->](`?User);
        }
    }
    can update with User entry {
        if self.name != None { here.name = self.name; }
        if self.interests != None { here.interests = self.interests; }
        if self.goals != None { here.goals = self.goals; }
        if self.target_role != None { here.target_role = self.target_role; }
        report {"status": "success", "message": "Profile updated"};
    }
}

walker add_skill {
    has skill_name: str;
    can start with `root entry {
        visit [-->](`?User) else {
            report {"error": "User not found"};
        }
    }
    can add with User entry {
        # Check if skill already exists
        let exists: bool = False;
        for s in [here ->:UserSkill:->] {
            if s.name == self.skill_name {
                exists = True;
                break;
            }
        }
        if not exists {
            here +>:UserSkill(level=50):+> Skill(name=self.skill_name);
        }
        report {"status": "success", "message": "Added skill " + str(self.skill_name)};
    }
}

walker delete_skill {
    has skill_name: str;
    can start with `root entry {
        visit [-->](`?User) else {
            report {"error": "User not found"};
        }
    }
    can delete with User entry {
        let deleted: bool = False;
        # Delete all matching skill nodes connected to the user
        for skill_node in [here ->:UserSkill:->] {
            if skill_node.name == self.skill_name {
                del skill_node;
                deleted = True;
            }
        }
        let status: str = "not-found";
        let message: str = "Skill " + str(self.skill_name) + " not found";
        if deleted {
            status = "success";
            message = "Deleted skill " + str(self.skill_name);
        }
        report {"status": status, "message": message};
    }
}

walker generate_roadmap {
    has target_role: str;
    can start with `root entry {
        let role_node = None;
        for r in [here -->](`?Role) {
            if r.title == self.target_role {
                role_node = r;
                break;
            }
        }
        if not role_node {
            role_node = here ++> Role(title=self.target_role, salary_range="Unknown");
        }
        visit [-->](`?User);
    }
    can analyze with User entry {
        let user_skills = [];
        for s in [here ->:UserSkill:->] {
            user_skills.append(s.name);
        }
        
        print("Generating roadmap for role: " + self.target_role);
        print("User skills: " + str(user_skills));
        
        # Call AI Agents
        let strategy = analyze_career_strategy(
            user_skills, 
            self.target_role, 
            here.interests,
            context="Return ONLY a valid JSON object. No Markdown. No code blocks. Structure: { 'strengths': [], 'gaps': [], 'recommendation': '' }"
        );
        print("Strategy generated: " + str(bool(strategy)));
        
        let market = analyze_market(
            self.target_role,
            context="Return ONLY a valid JSON object. No Markdown. No code blocks. Structure: { 'demand': 'High/Medium/Low', 'salary_range': '', 'top_companies': [] }"
        );
        print("Market analysis generated: " + str(bool(market)));
        
        # Extract gaps from strategy to create targeted learning plan
        let gaps_list = [];
        try {
            # Clean up potential markdown code blocks from strategy response
            let clean_strategy = strategy.replace("```json", "").replace("```", "").strip();
            let strategy_obj = loads(clean_strategy);
            if "gaps" in strategy_obj {
                gaps_list = strategy_obj["gaps"];
            }
        } except ex {
            print("Could not extract gaps from strategy: " + str(ex));
            print("Strategy content: " + strategy);
        }
        
        # If no gaps found or extraction failed, use user skills as fallback
        if not gaps_list or len(gaps_list) == 0 {
            print("No gaps found, using skills for learning plan");
            gaps_list = user_skills;
        }
        
        print("Gaps/skills for learning plan: " + str(gaps_list));
        
        let plan = create_learning_plan(
            gaps_list, 
            "3 months",
            context="Return ONLY a valid JSON object. No Markdown. No code blocks. Structure: { 'weeks': [ { 'week': 1, 'focus': '', 'resources': [] } ] }. Create a learning plan to acquire these missing skills/gaps."
        );
        print("Learning plan generated: " + str(bool(plan)));
        
        # Save to user node for persistence
        here.last_strategy = strategy;
        here.last_market = market;
        here.last_roadmap_plan = plan;
        here.target_role = self.target_role;
        
        print("Reporting results...");
        report {
            "target_role": self.target_role,
            "strategy": strategy,
            "market": market,
            "plan": plan
        };
    }
}

walker fetch_jobs {
    has role_filter: str = "";
    can start with `root entry {
        visit [-->](`?User);
    }
    can fetch with User entry {
        let user_skills = [];
        for s in [here ->:UserSkill:->] {
            user_skills.append(s.name);
        }
        
        # Call AI Agent
        let jobs_json = suggest_jobs(
            profile_skills=user_skills, 
            profile_interests=here.interests, 
            profile_goals=here.goals,
            role_filter=self.role_filter,
            context="Return ONLY a valid JSON list of objects. No Markdown. No code blocks. Structure: [ { 'title': '', 'company': '', 'match_score': 0-100 } ]"
        );
        
        try {
            # Clean up potential markdown code blocks from LLM response
            let clean_json = jobs_json.replace("```json", "").replace("```", "").strip();
            let jobs = loads(clean_json);
            
            # Save to user node for persistence
            here.last_jobs = jobs_json;
            here.jobs_role_filter = self.role_filter;
            
            report jobs;
        } except ex {
            # Fallback
            report [{"title": "Could not load smart suggestions", "company": "System", "posted": "Now"}];
            print("Error parsing jobs: " + str(ex));
        }
    }
}

# --- Frontend ---

cl import from "@jac-client/utils" {
    Router,
    Routes,
    Route
}

cl import from .frontend.components.Navbar { Navbar }
cl import from .frontend.pages.LoginPage { LoginPage }
cl import from .frontend.pages.SignupPage { SignupPage }
cl import from .frontend.pages.Dashboard { Dashboard }
cl import from .frontend.pages.CareerPath { CareerPath }
cl import from .frontend.pages.Jobs { Jobs }
cl import from .frontend.pages.Profile { Profile }

cl def app() -> any {
    return <Router>
        <div style={{"fontFamily": "system-ui, sans-serif", "background": "#f9fafb", "minHeight": "100vh"}}>
            <Navbar />
            <Routes>
                <Route path="/" element={<Dashboard />} />
                <Route path="/login" element={<LoginPage />} />
                <Route path="/signup" element={<SignupPage />} />
                <Route path="/career" element={<CareerPath />} />
                <Route path="/jobs" element={<Jobs />} />
                <Route path="/profile" element={<Profile />} />
            </Routes>
        </div>
    </Router>;
}
