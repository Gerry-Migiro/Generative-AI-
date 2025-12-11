# Backend Code
import from byllm.lib { Model }
import from json { loads, dumps }
import from urllib.request { urlopen, Request }

glob llm = Model(model_name="gemini/gemini-2.5-flash", verbose=False);

# --- Nodes ---
node User {
    has name: str = "";
    has interests: list = [];
    has goals: list = [];
    has target_role: str = "";
    has last_roadmap_plan: str = "[]";
    has last_strategy: str = "[]";
    has last_market: str = "[]";
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

edge RequiresSkill {
    has importance: int = 5;  # 1-10 scale: how critical this skill is for the role
}

edge PrerequisiteOf {
    has difficulty_gap: int = 1;  # How many levels harder (1=easy step, 5=major leap)
}

# --- Agents ---
# Multi-Agent System: Career Advisor with 3 specialized agents
# Agent Flow: User Request → generate_roadmap → analyze_career_strategy → analyze_market → create_learning_plan

# Agent 1: Career Strategy Analyzer - Identifies strengths and skill gaps
def analyze_career_strategy(
    user_skills: list, target_role: str, user_interests: list, context: str
) -> str by llm(method="Reason");

# Agent 2: Market Research Analyzer - Researches job market trends
def analyze_market(
    role_title: str, context: str
) -> str by llm(method="Reason");

# Agent 3: Learning Path Designer - Creates personalized learning roadmap
def create_learning_plan(
    missing_skills: list, timeline: str, context: str
) -> str by llm(method="Reason");

"""Extract technical skills from resume text. Return only concrete tools, languages, frameworks, and technologies as nouns. Skip job titles, company names, soft skills, general and unecessary descriptions."""
def resume_parser(resume_text: str) -> list[str] by llm(method="Reason");

# --- OSP Graph Traversal Walker ---
walker calculate_role_match {
    has target_role: str;
    has match_score: float = 0.0;
    has required_skills: list = [];
    has missing_skills: list = [];
    has matched_skills: list = [];

    can find_role with `root entry {
        # Find target role node using graph traversal
        let role_node = None;
        for r in [here-->](`?Role) {
            if r.title == self.target_role {
                role_node = r;
                visit role_node;
            }
        }
        if not role_node {
            report {"error": "Role not found", "score": 0.0} ;
        }
    }

    can score_match with Role entry {
        # OSP Graph Reasoning: Traverse Role->RequiresSkill->Skill edges
        let total_importance = 0;
        let matched_importance = 0;

        # Get user node to check skills
        let user_node = None;
        for u in [root-->](`?User) {
            user_node = u;
            break;
        }

        if not user_node {
            report {"error": "User not found", "score": 0.0} ;
            return;
        }

        # Collect user's skills
        let user_skills = [];
        for s in [user_node->:UserSkill:->] {
            user_skills.append(s.name);
        }

        # Traverse role requirements using OSP edge filtering
        for skill_edge in [here->:RequiresSkill:->] {
            let skill_node = [here->:RequiresSkill:->(`?Skill)][-1];
            if skill_node {
                let importance = 5;  # default
                # Get actual importance from edge
                for e in [here->:RequiresSkill:target==skill_node:->] {
                    importance = e.importance if hasattr(e, 'importance') else 5;
                    break;
                }
                total_importance += importance;
                self.required_skills.append(skill_node.name);
                # Check if user has this skill
                if skill_node.name in user_skills {
                    matched_importance += importance;
                    self.matched_skills.append(skill_node.name);
                } else {
                    self.missing_skills.append(skill_node.name);
                }
            }
        }

        # Calculate match score (0-100)
        if total_importance > 0 {
            self.match_score = (matched_importance / total_importance) * 100;
        } else {
            self.match_score = 0.0;
        }

        report {
            "role": self.target_role,
            "match_score": round(self.match_score, 2),
            "required_skills": self.required_skills,
            "matched_skills": self.matched_skills,
            "missing_skills": self.missing_skills,
            "total_importance": total_importance,
            "matched_importance": matched_importance
        } ;
    }
}

# --- Walkers ---
walker seed_database {
    can seed with `root entry {
        # Check if already seeded by looking for jobs
        let existing_jobs = [here-->](`?JobPosting);
        if len(existing_jobs) > 0 {
            print("Database already seeded");
            return;
        }

        print("Seeding database...");

        # Create Roles
        here ++> Role(
            title="Software Developer",
            salary_range="$80k - $150k",
            description="Builds software applications"
        );
        here ++> Role(
            title="Data Scientist",
            salary_range="$100k - $180k",
            description="Analyzes complex data"
        );
        here ++> Role(
            title="Product Manager",
            salary_range="$90k - $160k",
            description="Oversees product development"
        );
        here ++> Role(
            title="DevOps Engineer",
            salary_range="$90k - $160k",
            description="Manages infrastructure and deployments"
        );
        here ++> Role(
            title="UX Designer",
            salary_range="$70k - $130k",
            description="Designs user experiences"
        );

        # Create Courses
        here ++> Course(
            title="Python Programming Masterclass",
            url="https://udemy.com/python",
            duration="40 hours"
        );
        here ++> Course(
            title="Data Science Bootcamp",
            url="https://coursera.org/data-science",
            duration="3 months"
        );
        here ++> Course(
            title="Web Development Complete",
            url="https://udemy.com/web-dev",
            duration="60 hours"
        );
        here ++> Course(
            title="Machine Learning Specialization",
            url="https://coursera.org/ml",
            duration="4 months"
        );
        here ++> Course(
            title="AWS Cloud Practitioner",
            url="https://aws.amazon.com/training",
            duration="20 hours"
        );
        here ++> Course(
            title="React Advanced Patterns",
            url="https://frontendmasters.com/react",
            duration="25 hours"
        );
        here ++> Course(
            title="SQL for Data Analysis",
            url="https://udacity.com/sql",
            duration="30 hours"
        );
        here ++> Course(
            title="Product Management Fundamentals",
            url="https://coursera.org/product-management",
            duration="6 weeks"
        );
        here ++> Course(
            title="DevOps Engineering Bootcamp",
            url="https://udemy.com/devops",
            duration="50 hours"
        );
        here ++> Course(
            title="UX Design Principles",
            url="https://interaction-design.org/ux",
            duration="8 weeks"
        );

        # Create Skills
        let skill_python = here ++> Skill(name="Python");
        let skill_js = here ++> Skill(name="JavaScript");
        let skill_react = here ++> Skill(name="React");
        let skill_ml = here ++> Skill(name="Machine Learning");
        let skill_aws = here ++> Skill(name="AWS");
        let skill_pandas = here ++> Skill(name="Pandas");
        let skill_sql = here ++> Skill(name="SQL");
        let skill_docker = here ++> Skill(name="Docker");
        let skill_figma = here ++> Skill(name="Figma");
        let skill_agile = here ++> Skill(name="Agile");

        # OSP Graph: Create Role->Skill relationships with RequiresSkill edges
        # Get role references
        let roles = [here-->](`?Role);
        let role_softdev = None;
        let role_datascience = None;
        let role_productmgr = None;
        let role_devops = None;
        let role_ux = None;

        for r in roles {
            if r.title == "Software Developer" {
                role_softdev = r;
            } elif r.title == "Data Scientist" {
                role_datascience = r;
            } elif r.title == "Product Manager" {
                role_productmgr = r;
            } elif r.title == "DevOps Engineer" {
                role_devops = r;
            } elif r.title == "UX Designer" {
                role_ux = r;
            }
        }

        # Software Developer requires these skills (importance 1-10)
        if role_softdev {
            role_softdev +>: RequiresSkill(importance=9) :+> skill_python;
            role_softdev +>: RequiresSkill(importance=8) :+> skill_js;
            role_softdev +>: RequiresSkill(importance=7) :+> skill_react;
            role_softdev +>: RequiresSkill(importance=6) :+> skill_sql;
            role_softdev +>: RequiresSkill(importance=5) :+> skill_docker;
        }

        # Data Scientist requires these skills
        if role_datascience {
            role_datascience +>: RequiresSkill(importance=10) :+> skill_python;
            role_datascience +>: RequiresSkill(importance=9) :+> skill_ml;
            role_datascience +>: RequiresSkill(importance=8) :+> skill_pandas;
            role_datascience +>: RequiresSkill(importance=7) :+> skill_sql;
        }

        # DevOps Engineer requires these skills
        if role_devops {
            role_devops +>: RequiresSkill(importance=9) :+> skill_docker;
            role_devops +>: RequiresSkill(importance=8) :+> skill_aws;
            role_devops +>: RequiresSkill(importance=7) :+> skill_python;
            role_devops +>: RequiresSkill(importance=6) :+> skill_sql;
        }

        # Product Manager requires these skills
        if role_productmgr {
            role_productmgr +>: RequiresSkill(importance=8) :+> skill_agile;
            role_productmgr +>: RequiresSkill(importance=5) :+> skill_sql;
        }

        # UX Designer requires these skills
        if role_ux {
            role_ux +>: RequiresSkill(importance=10) :+> skill_figma;
            role_ux +>: RequiresSkill(importance=4) :+> skill_js;
        }

        # OSP Graph: Create Skill->Skill prerequisites with PrerequisiteOf edges
        # Python is prerequisite for more advanced skills
        skill_python +>: PrerequisiteOf(difficulty_gap=2) :+> skill_pandas;
        skill_python +>: PrerequisiteOf(difficulty_gap=3) :+> skill_ml;
        skill_js +>: PrerequisiteOf(difficulty_gap=2) :+> skill_react;
        skill_sql +>: PrerequisiteOf(difficulty_gap=3) :+> skill_ml;

        # Create Job Postings
        here ++> JobPosting(
            title="Software Developer",
            company="TechCorp Inc.",
            posted_date="2024-12-01"
        );
        here ++> JobPosting(
            title="Senior Software Engineer",
            company="Google",
            posted_date="2024-12-05"
        );
        here ++> JobPosting(
            title="Full Stack Developer", company="Microsoft", posted_date="2024-12-03"
        );
        here ++> JobPosting(
            title="Data Scientist", company="Amazon", posted_date="2024-12-02"
        );
        here ++> JobPosting(
            title="ML Engineer", company="Meta", posted_date="2024-12-06"
        );
        here ++> JobPosting(
            title="Product Manager", company="Apple", posted_date="2024-12-04"
        );
        here ++> JobPosting(
            title="Senior Product Manager", company="Netflix", posted_date="2024-12-07"
        );
        here ++> JobPosting(
            title="DevOps Engineer", company="Spotify", posted_date="2024-12-01"
        );
        here ++> JobPosting(
            title="Cloud Engineer", company="IBM", posted_date="2024-12-05"
        );
        here ++> JobPosting(
            title="UX Designer", company="Adobe", posted_date="2024-12-03"
        );
        here ++> JobPosting(
            title="Senior UX/UI Designer", company="Figma", posted_date="2024-12-06"
        );
        here ++> JobPosting(
            title="Backend Developer", company="Stripe", posted_date="2024-12-02"
        );
        here ++> JobPosting(
            title="Frontend Developer", company="Airbnb", posted_date="2024-12-04"
        );
        here ++> JobPosting(
            title="Data Analyst", company="Salesforce", posted_date="2024-12-07"
        );
        here ++> JobPosting(
            title="Python Developer", company="Dropbox", posted_date="2024-12-01"
        );

        print("Database seeded successfully");
    }
}

walker get_all_roles {
    can return_roles with `root entry {
        let roles = [here-->](`?Role);
        if len(roles) == 0 {
            # Auto-seed if no roles exist
            here spawn seed_database();
            roles = [here-->](`?Role);
        }

        let role_list = [];
        for r in roles {
            role_list.append(
                {
                    "title": r.title,
                    "description": r.description,
                    "salary": r.salary_range
                }
            );
        }
        report role_list ;
    }
}

walker get_recommended_courses {
    can recommend with `root entry {
        # Get all courses and return them
        let all_courses = [-->](`?Course);
        let course_list = [];
        for course in all_courses {
            course_list.append(
                {"title": course.title, "url": course.url, "duration": course.duration}
            );
        }
        report course_list ;
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
        for s in [here->:UserSkill:->] {
            current_skills.append(s.name);
        }

        # Add new skills from resume
        let added_skills = [];
        let skipped_skills = [];

        for skill_name in skill_list {
            if skill_name not in current_skills {
                # Create new skill and connect (simple approach)
                here +>: UserSkill(level=50) :+> Skill(name=skill_name);
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
        } ;
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
        for s in [here->:UserSkill:->] {
            skills.append(s.name);
        }
        report {
            "name": here.name,
            "interests": here.interests,
            "goals": here.goals,
            "skills": skills,
            "target_role": here.target_role,
            "last_roadmap_plan": here.last_roadmap_plan,
            "last_strategy": here.last_strategy,
            "last_market": here.last_market
        } ;
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
        if self.name != None {
            here.name = self.name;
        }
        if self.interests != None {
            here.interests = self.interests;
        }
        if self.goals != None {
            here.goals = self.goals;
        }
        if self.target_role != None {
            here.target_role = self.target_role;
        }
        report {"status": "success", "message": "Profile updated"} ;
    }
}

walker add_skill {
    has skill_name: str;

    can start with `root entry {
        visit [-->](`?User) else {
            report {"error": "User not found"} ;
        }
    }

    can add with User entry {
        # Check if skill already exists
        let exists: bool = False;
        for s in [here->:UserSkill:->] {
            if s.name == self.skill_name {
                exists = True;
                break;
            }
        }
        if not exists {
            here +>: UserSkill(level=50) :+> Skill(name=self.skill_name);
        }
        report {"status": "success", "message": "Added skill " + str(self.skill_name)} ;
    }
}

walker delete_skill {
    has skill_name: str;

    can start with `root entry {
        visit [-->](`?User) else {
            report {"error": "User not found"} ;
        }
    }

    can delete with User entry {
        let deleted: bool = False;
        # Delete all matching skill nodes connected to the user
        for skill_node in [here->:UserSkill:->] {
            if skill_node.name == self.skill_name {
                del skill_node ;
                deleted = True;
            }
        }
        let status: str = "not-found";
        let message: str = "Skill " + str(self.skill_name) + " not found";
        if deleted {
            status = "success";
            message = "Deleted skill " + str(self.skill_name);
        }
        report {"status": status, "message": message} ;
    }
}

walker generate_roadmap {
    has target_role: str;

    can start with `root entry {
        let role_node = None;
        for r in [here-->](`?Role) {
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
        for s in [here->:UserSkill:->] {
            user_skills.append(s.name);
        }

        print("Generating roadmap for role: " + self.target_role);
        print("User skills: " + str(user_skills));

        # OSP Graph Analysis: Calculate role match using graph traversal
        let graph_match = None;
        try {
            let matcher = calculate_role_match(target_role=self.target_role) spawn root;
            if matcher and len(matcher.reports) > 0 {
                graph_match = matcher.reports[0];
                print(
                    "OSP Graph Match Score: " + str(graph_match.get("match_score", 0)) + "%"
                );
            }
        } except Exception as e {
            print("Graph match calculation skipped: " + str(e));
        }

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
        } except Exception {
            print("Could not extract gaps from strategy");
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

        # Include OSP graph match data in response
        let response = {
            "target_role": self.target_role,
            "strategy": strategy,
            "market": market,
            "plan": plan
        };

        if graph_match {
            response["graph_match"] = graph_match;
        }

        report response ;
    }
}

walker fetch_jobs {
    has role_filter: str = "";

    can fetch with `root entry {
        let jobs_list = [];

        try {
            # Fetch from Remotive API (Software Development category)
            # Increased limit to 50 to get more variety
            let url = "https://remotive.com/api/remote-jobs?category=software-dev&limit=50";

            let request = Request(url);
            request.add_header("User-Agent", "Mozilla/5.0 (Career-Advisory-App)");
            let response = urlopen(request);
            let data = response.read().decode("utf-8");
            let json_data = loads(data);

            if "jobs" in json_data {
                for job in json_data["jobs"] {
                    if len(jobs_list) >= 50 {
                        break;
                    }

                    let job_title = job["title"];

                    # Simple filter if user specified a role
                    if self.role_filter != "" {
                        let filter_lower = self.role_filter.lower();
                        let title_lower = job_title.lower();
                        if filter_lower not in title_lower {
                            continue;
                        }
                    }

                    jobs_list.append(
                        {
                            "title": job_title,
                            "company": job["company_name"],
                            "location": job["candidate_required_location"],
                            "posted_date": job["publication_date"][:10],
                            "match_score": 85
                        }
                    );
                }
            }
        } except Exception as e {
            print(f"Error fetching jobs: {e}");
        }

        # Fallback to seeded jobs if API fails OR returns no results
        if len(jobs_list) == 0 {
            print("No jobs from API, using seeded data");
            let all_jobs = [root-->](`?JobPosting);
            for job in all_jobs {
                if self.role_filter == ""
                or self.role_filter.lower() in job.title.lower() {
                    jobs_list.append(
                        {
                            "title": job.title,
                            "company": job.company,
                            "location": "Remote",
                            "posted_date": job.posted_date,
                            "match_score": 75
                        }
                    );
                }
            }
        }

        # Return jobs or empty list
        if len(jobs_list) > 0 {
            report jobs_list ;
        } else {
            report [
                {
                    "title": "No jobs found",
                    "company": "Try a different search",
                    "posted_date": "N/A",
                    "match_score": 0
                }
            ] ;
        }
    }
}

# --- Frontend ---
cl import from "@jac-client/utils" { Router, Routes, Route }

cl import from .frontend.components.Navbar { Navbar }
cl import from .frontend.pages.LoginPage { LoginPage }
cl import from .frontend.pages.SignupPage { SignupPage }
cl import from .frontend.pages.Dashboard { Dashboard }
cl import from .frontend.pages.CareerPath { CareerPath }
cl import from .frontend.pages.Jobs { Jobs }
cl import from .frontend.pages.Profile { Profile }
cl import from .frontend.pages.Courses { Courses }

# Import Global Styles
cl import "../frontend/globals.css";

cl def app()  -> any {
    return <Router>
        <div className="app-container">
            <Navbar />
            <Routes>
                <Route
                    path="/"
                    element={<Dashboard />}
                />
                <Route
                    path="/login"
                    element={<LoginPage />}
                />
                <Route
                    path="/signup"
                    element={<SignupPage />}
                />
                <Route
                    path="/career"
                    element={<CareerPath />}
                />
                <Route
                    path="/jobs"
                    element={<Jobs />}
                />
                <Route
                    path="/profile"
                    element={<Profile />}
                />
                <Route
                    path="/courses"
                    element={<Courses />}
                />
            </Routes>
        </div>
    </Router>;
}
