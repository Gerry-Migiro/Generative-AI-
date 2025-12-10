cl import from react { useState, useEffect }
cl import from "@jac-client/utils" { Link, useNavigate, jacIsLoggedIn, Navigate }

walker get_profile {}

cl def Dashboard()  -> any {
    if not jacIsLoggedIn() {
        return <Navigate to="/login" />;
    }
    let [profile, setProfile] = useState(None);
    let [gaps, setGaps] = useState([]);
    let [roadmap, setRoadmap] = useState([]);
    let navigate = useNavigate();

    async def loadData()  -> None {
        try {
            res = await root spawn get_profile();
            if res.reports {
                let p = res.reports[0];
                if p and not p["error"] {
                    setProfile(p);
                    # Redirect to profile if name is empty
                    if not p["name"] or p["name"] == "" {
                        navigate("/profile");
                        return;
                    }
                    # Parse strategy to extract gaps
                    if p["last_strategy"] and p["last_strategy"] != "[]" {
                        try {
                            let clean_strategy = p["last_strategy"].replace(
                                "```json", ""
                            ).replace(
                                "```", ""
                            ).trim();
                            let strategy = JSON.parse(clean_strategy);
                            if strategy.gaps && Array.isArray(strategy.gaps) {
                                setGaps(strategy.gaps);
                            }
                        } except ex1 {
                            console.error("Error parsing strategy:", ex1);
                        }
                    }
                    # Parse learning plan
                    if p["last_roadmap_plan"] and p["last_roadmap_plan"] != "[]" {
                        try {
                            let clean_plan = p["last_roadmap_plan"].replace(
                                "```json", ""
                            ).replace(
                                "```", ""
                            ).trim();
                            let plan = JSON.parse(clean_plan);
                            if plan.weeks {
                                setRoadmap(plan.weeks);
                            }
                        } except ex2 {
                            console.error("Error parsing plan:", ex2);
                        }
                    }
                } else {
                    console.error("Profile load error:", p);
                    setProfile(
                        {
                            "name": "",
                            "interests": [],
                            "goals": [],
                            "skills": [],
                            "target_role": ""
                        }
                    );
                }
            } else {
                console.error("No reports in response");
                setProfile(
                    {
                        "name": "",
                        "interests": [],
                        "goals": [],
                        "skills": [],
                        "target_role": ""
                    }
                );
            }
        } except ex {
            console.error("Error loading dashboard:", ex);
            setProfile(
                {
                    "name": "",
                    "interests": [],
                    "goals": [],
                    "skills": [],
                    "target_role": ""
                }
            );
        }
    }

    useEffect(lambda   -> None{ loadData();} , []);

    if not profile {
        return <div
            style={{"padding": "4rem", "textAlign": "center", "color": "#64748b"}}
        >
            Loading dashboard...
        </div>;
    }

    return <div
        className="container"
        style={{"maxWidth": "1200px", "padding": "2rem 1rem"}}
    >
        <div
            className="flex-between"
            style={{"flexWrap": "wrap", "gap": "1rem", "marginBottom": "2rem"}}
        >
            <div>
                <h1
                    style={{
                        "margin": 0,
                        "fontSize": "2rem",
                        "color": "var(--foreground)"
                    }}
                >
                    Career Command Center
                </h1>
                <p
                    style={{
                        "margin": "0.5rem 0 0 0",
                        "color": "var(--muted-foreground)"
                    }}
                >
                    Track your progress and seize new opportunities
                </p>
            </div>
        </div>
        <div className="grid-dashboard">
            <div className="card">
                <div className="text-label">
                    Target Role
                </div>
                <div className="text-value">
                    {profile["target_role"] if profile["target_role"] else "Not Set"}
                </div>
                {not profile["target_role"]
                and <Link
                    to="/profile"
                    style={{
                        "display": "inline-block",
                        "marginTop": "1rem",
                        "fontSize": "0.875rem",
                        "color": "var(--brand)",
                        "textDecoration": "none"
                    }}
                >
                    Set a goal →
                </Link>}
            </div>
            <div className="card">
                <div className="text-label">
                    Skills Acquired
                </div>
                <div className="text-value">
                    {profile["skills"].length}
                </div>
                <div className="text-sub">
                    Verified skills
                </div>
            </div>
            <div className="card">
                <div className="text-label">
                    Skill Gaps
                </div>
                <div
                    className="text-value"
                    style={{"color": "var(--error)"}}
                >
                    {gaps.length}
                </div>
                <div className="text-sub">
                    Areas for improvement
                </div>
            </div>
        </div>
        <div className="grid-cols-2">
            <div className="card">
                <div
                    className="flex-between"
                    style={{
                        "marginBottom": "1.5rem",
                        "borderBottom": "1px solid var(--border)",
                        "paddingBottom": "1rem"
                    }}
                >
                    <h3
                        style={{"fontSize": "1.1rem", "margin": "0"}}
                    >
                        Recommended Path
                    </h3>
                    <Link
                        to="/career"
                        state={{"scrollTo": "learningPlan"}}
                        style={{
                            "fontSize": "0.875rem",
                            "color": "var(--brand)",
                            "textDecoration": "none",
                            "fontWeight": "500"
                        }}
                    >
                        View Full Plan →
                    </Link>
                </div>
                {roadmap.length > 0
                and <div className="flex-col gap-sm">
                    {roadmap.map(
                        lambda  step: any  -> any{ return <div
                            style={{
                                "display": "flex",
                                "alignItems": "center",
                                "gap": "0.5rem",
                                "padding": "0.25rem 0"
                            }}
                        >
                            <div
                                style={{
                                    "width": "24px",
                                    "height": "24px",
                                    "borderRadius": "50%",
                                    "background": "var(--brand)",
                                    "color": "white",
                                    "display": "flex",
                                    "alignItems": "center",
                                    "justifyContent": "center",
                                    "fontSize": "0.7rem",
                                    "fontWeight": "600",
                                    "flexShrink": "0"
                                }}
                            >
                                {step["week"]}
                            </div>
                            <div
                                style={{"fontSize": "0.85rem", "fontWeight": "500"}}
                            >
                                {step["focus"]}
                            </div>
                        </div>; }
                    )}
                </div>}
                {roadmap.length == 0
                and <div
                    style={{
                        "textAlign": "center",
                        "padding": "2rem 0",
                        "color": "oklch(0.55 0.03 286)"
                    }}
                >
                    <p>
                        No active learning path.
                    </p>
                    <Link
                        to="/career"
                        state={{"role": profile["target_role"], "run": True}}
                        className="btn btn-secondary"
                        style={{"display": "inline-block", "marginTop": "0.5rem"}}
                    >
                        Generate Roadmap
                    </Link>
                </div>}
            </div>
            <div
                className="flex-col"
                style={{"gap": "2rem"}}
            >
                <div className="card">
                    <h3 className="section-title">
                        Skill Gaps
                    </h3>
                    {gaps.length > 0
                    and <div
                        className="flex-col"
                        style={{"gap": "0.75rem"}}
                    >
                        {gaps.slice(0, 4).map(
                            lambda  gap: any  -> any{ return <div className="alert-red">
                                <span>
                                    • {gap}
                                </span>
                            </div>; }
                        )}
                    </div>}
                    {gaps.length == 0
                    and <div
                        className="text-sub"
                        style={{"fontStyle": "italic"}}
                    >
                        No gaps identified yet.
                    </div>}
                </div>
                <div className="card">
                    <h3 className="section-title">
                        Recommended Skills
                    </h3>
                    <div className="flex-col" style={{"gap": "0.5rem", "width": "100%"}}>
                        {gaps.length > 0 and gaps.map(
                            lambda  g: any  -> any{ return <div style={{
                                "background": "#fefce8",
                                "border": "1px solid #fef08a",
                                "borderRadius": "6px",
                                "padding": "0.75rem",
                                "color": "#854d0e",
                                "fontSize": "0.9rem",
                                "lineHeight": "1.5"
                            }}>
                                {g}
                            </div>; }
                        )}
                        {gaps.length == 0
                        and <span className="text-sub">
                            No recommendations yet.
                        </span>}
                    </div>
                </div>
                <div className="card">
                    <h3 className="section-title">
                        My Skills
                    </h3>
                    <div
                        style={{"display": "flex", "flexWrap": "wrap", "gap": "0.5rem"}}
                    >
                        {profile["skills"].length > 0
                        and profile["skills"].map(
                            lambda  s: any  -> any{ return <span className="badge badge-gray">
                                {s}
                            </span>; }
                        )}{profile["skills"].length == 0
                        and <span className="text-sub">
                            No skills added.
                        </span>}
                    </div>
                </div>
            </div>
        </div>
    </div>;
}
