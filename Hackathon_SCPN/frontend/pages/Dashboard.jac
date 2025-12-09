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
                            let clean_strategy = p["last_strategy"].replace("```json", "").replace("```", "").trim();
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
                            let clean_plan = p["last_roadmap_plan"].replace("```json", "").replace("```", "").trim();
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
                    setProfile({"name": "", "interests": [], "goals": [], "skills": [], "target_role": ""});
                }
            } else {
                console.error("No reports in response");
                setProfile({"name": "", "interests": [], "goals": [], "skills": [], "target_role": ""});
            }
        } except ex {
            console.error("Error loading dashboard:", ex);
            setProfile({"name": "", "interests": [], "goals": [], "skills": [], "target_role": ""});
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
        style={{
            "maxWidth": "1200px",
            "margin": "0 auto",
            "padding": "2rem",
            "fontFamily": "sans-serif",
            "color": "#1e293b"
        }}
    >
        <div
            style={{
                "marginBottom": "2rem",
                "borderBottom": "1px solid #e2e8f0",
                "paddingBottom": "1rem",
                "display": "flex",
                "justifyContent": "space-between",
                "alignItems": "center"
            }}
        >
            <div>
                <h1
                    style={{
                        "fontSize": "1.8rem",
                        "fontWeight": "700",
                        "color": "#0f172a",
                        "margin": "0"
                    }}
                >
                    Dashboard
                </h1>
                <p
                    style={{"color": "#64748b", "margin": "0.5rem 0 0 0"}}
                >
                    Overview of your career progress and goals.
                </p>
            </div>
            <button
                onClick={loadData}
                style={{
                    "padding": "0.5rem 1rem",
                    "background": "white",
                    "border": "1px solid #cbd5e1",
                    "borderRadius": "4px",
                    "cursor": "pointer",
                    "color": "#475569"
                }}
            >
                Refresh Data
            </button>
        </div>
        <div
            style={{
                "display": "grid",
                "gridTemplateColumns": "repeat(auto-fit, minmax(250px, 1fr))",
                "gap": "1.5rem",
                "marginBottom": "2rem"
            }}
        >
            <div
                style={{
                    "background": "white",
                    "border": "1px solid #e2e8f0",
                    "borderRadius": "8px",
                    "padding": "1.5rem",
                    "boxShadow": "0 1px 2px rgba(0,0,0,0.05)"
                }}
            >
                <div
                    style={{
                        "fontSize": "0.875rem",
                        "fontWeight": "600",
                        "color": "#64748b",
                        "textTransform": "uppercase",
                        "letterSpacing": "0.05em"
                    }}
                >
                    Target Role
                </div>
                <div
                    style={{
                        "fontSize": "1.5rem",
                        "fontWeight": "700",
                        "color": "#0f172a",
                        "marginTop": "0.5rem"
                    }}
                >
                    {profile["target_role"] if profile["target_role"] else "Not Set"}
                </div>
                {not profile["target_role"]
                and <Link
                    to="/profile"
                    style={{
                        "display": "inline-block",
                        "marginTop": "1rem",
                        "fontSize": "0.875rem",
                        "color": "#2563eb",
                        "textDecoration": "none"
                    }}
                >
                    Set a goal →
                </Link>}
            </div>
            <div
                style={{
                    "background": "white",
                    "border": "1px solid #e2e8f0",
                    "borderRadius": "8px",
                    "padding": "1.5rem",
                    "boxShadow": "0 1px 2px rgba(0,0,0,0.05)"
                }}
            >
                <div
                    style={{
                        "fontSize": "0.875rem",
                        "fontWeight": "600",
                        "color": "#64748b",
                        "textTransform": "uppercase",
                        "letterSpacing": "0.05em"
                    }}
                >
                    Skills Acquired
                </div>
                <div
                    style={{
                        "fontSize": "1.5rem",
                        "fontWeight": "700",
                        "color": "#0f172a",
                        "marginTop": "0.5rem"
                    }}
                >
                    {profile["skills"].length}
                </div>
                <div
                    style={{
                        "fontSize": "0.875rem",
                        "color": "#64748b",
                        "marginTop": "0.5rem"
                    }}
                >
                    Verified skills
                </div>
            </div>
            <div
                style={{
                    "background": "white",
                    "border": "1px solid #e2e8f0",
                    "borderRadius": "8px",
                    "padding": "1.5rem",
                    "boxShadow": "0 1px 2px rgba(0,0,0,0.05)"
                }}
            >
                <div
                    style={{
                        "fontSize": "0.875rem",
                        "fontWeight": "600",
                        "color": "#64748b",
                        "textTransform": "uppercase",
                        "letterSpacing": "0.05em"
                    }}
                >
                    Skill Gaps
                </div>
                <div
                    style={{
                        "fontSize": "1.5rem",
                        "fontWeight": "700",
                        "color": "#ef4444",
                        "marginTop": "0.5rem"
                    }}
                >
                    {gaps.length}
                </div>
                <div
                    style={{
                        "fontSize": "0.875rem",
                        "color": "#64748b",
                        "marginTop": "0.5rem"
                    }}
                >
                    Areas for improvement
                </div>
            </div>
        </div>
        <div
            style={{
                "display": "grid",
                "gridTemplateColumns": "repeat(auto-fit, minmax(400px, 1fr))",
                "gap": "2rem"
            }}
        >
            <div
                style={{
                    "background": "white",
                    "border": "1px solid #e2e8f0",
                    "borderRadius": "8px",
                    "padding": "1.5rem",
                    "boxShadow": "0 1px 2px rgba(0,0,0,0.05)"
                }}
            >
                <div
                    style={{
                        "display": "flex",
                        "justifyContent": "space-between",
                        "alignItems": "center",
                        "marginBottom": "1.5rem",
                        "borderBottom": "1px solid #f1f5f9",
                        "paddingBottom": "1rem"
                    }}
                >
                    <h3
                        style={{
                            "fontSize": "1.1rem",
                            "fontWeight": "600",
                            "color": "#0f172a",
                            "margin": "0"
                        }}
                    >
                        Recommended Path
                    </h3>
                    <Link
                        to="/career"
                        state={{"scrollTo": "learningPlan"}}
                        style={{
                            "fontSize": "0.875rem",
                            "color": "#2563eb",
                            "textDecoration": "none",
                            "fontWeight": "500"
                        }}
                    >
                        View Full Plan →
                    </Link>
                </div>
                {roadmap.length > 0
                and <div
                    style={{
                        "display": "flex",
                        "flexDirection": "column",
                        "gap": "0.5rem"
                    }}
                >
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
                                    "background": "#3b82f6",
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
                                style={{
                                    "fontSize": "0.85rem",
                                    "color": "#1e293b",
                                    "fontWeight": "500",
                                    "lineHeight": "1.4"
                                }}
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
                        "color": "#64748b"
                    }}
                >
                    <p>
                        No active learning path.
                    </p>
                    <Link
                        to="/career"
                        state={{"role": profile["target_role"], "run": True}}
                        style={{
                            "display": "inline-block",
                            "marginTop": "0.5rem",
                            "padding": "0.5rem 1rem",
                            "background": "#f1f5f9",
                            "color": "#334155",
                            "borderRadius": "6px",
                            "textDecoration": "none",
                            "fontSize": "0.875rem",
                            "fontWeight": "500"
                        }}
                    >
                        Generate Roadmap
                    </Link>
                </div>}
            </div>
            <div
                style={{"display": "flex", "flexDirection": "column", "gap": "2rem"}}
            >
                <div
                    style={{
                        "background": "white",
                        "border": "1px solid #e2e8f0",
                        "borderRadius": "8px",
                        "padding": "1.5rem",
                        "boxShadow": "0 1px 2px rgba(0,0,0,0.05)"
                    }}
                >
                    <h3
                        style={{
                            "fontSize": "1.1rem",
                            "fontWeight": "600",
                            "color": "#0f172a",
                            "margin": "0 0 1.5rem 0",
                            "borderBottom": "1px solid #f1f5f9",
                            "paddingBottom": "1rem"
                        }}
                    >
                        Skill Gaps
                    </h3>
                    {gaps.length > 0
                    and <div
                        style={{
                            "display": "flex",
                            "flexDirection": "column",
                            "gap": "0.75rem"
                        }}
                    >
                        {gaps.slice(0, 4).map(
                            lambda  gap: any  -> any{ return <div
                                style={{
                                    "padding": "0.5rem",
                                    "background": "#fef2f2",
                                    "border": "1px solid #fecaca",
                                    "borderRadius": "6px"
                                }}
                            >
                                <span
                                    style={{
                                        "fontSize": "0.875rem",
                                        "color": "#991b1b",
                                        "fontWeight": "500"
                                    }}
                                >
                                    • {gap}
                                </span>
                            </div>; }
                        )}
                    </div>}
                    {gaps.length == 0
                    and <div
                        style={{
                            "color": "#64748b",
                            "fontSize": "0.875rem",
                            "fontStyle": "italic"
                        }}
                    >
                        No gaps identified yet.
                    </div>}
                </div>
                <div
                    style={{
                        "background": "white",
                        "border": "1px solid #e2e8f0",
                        "borderRadius": "8px",
                        "padding": "1.5rem",
                        "boxShadow": "0 1px 2px rgba(0,0,0,0.05)"
                    }}
                >
                    <h3
                        style={{
                            "fontSize": "1.1rem",
                            "fontWeight": "600",
                            "color": "#0f172a",
                            "margin": "0 0 1.5rem 0",
                            "borderBottom": "1px solid #f1f5f9",
                            "paddingBottom": "1rem"
                        }}
                    >
                        Recommended Skills
                    </h3>
                    <div
                        style={{"display": "flex", "flexWrap": "wrap", "gap": "0.5rem"}}
                    >
                        {gaps.length > 0
                        and gaps.map(
                            lambda  g: any  -> any{ return <span
                                style={{
                                    "background": "#fef3c7",
                                    "border": "1px solid #fde68a",
                                    "color": "#92400e",
                                    "padding": "0.25rem 0.75rem",
                                    "borderRadius": "9999px",
                                    "fontSize": "0.875rem",
                                    "fontWeight": "500"
                                }}
                            >
                                {g}
                            </span>; }
                        )}{gaps.length == 0
                        and <span
                            style={{"color": "#64748b", "fontSize": "0.875rem"}}
                        >
                            No recommendations yet.
                        </span>}
                    </div>
                </div>
                <div
                    style={{
                        "background": "white",
                        "border": "1px solid #e2e8f0",
                        "borderRadius": "8px",
                        "padding": "1.5rem",
                        "boxShadow": "0 1px 2px rgba(0,0,0,0.05)"
                    }}
                >
                    <h3
                        style={{
                            "fontSize": "1.1rem",
                            "fontWeight": "600",
                            "color": "#0f172a",
                            "margin": "0 0 1.5rem 0",
                            "borderBottom": "1px solid #f1f5f9",
                            "paddingBottom": "1rem"
                        }}
                    >
                        My Skills
                    </h3>
                    <div
                        style={{"display": "flex", "flexWrap": "wrap", "gap": "0.5rem"}}
                    >
                        {profile["skills"].length > 0
                        and profile["skills"].map(
                            lambda  s: any  -> any{ return <span
                                style={{
                                    "background": "#f8fafc",
                                    "border": "1px solid #e2e8f0",
                                    "color": "#475569",
                                    "padding": "0.25rem 0.75rem",
                                    "borderRadius": "9999px",
                                    "fontSize": "0.875rem",
                                    "fontWeight": "500"
                                }}
                            >
                                {s}
                            </span>; }
                        )}{profile["skills"].length == 0
                        and <span
                            style={{"color": "#64748b", "fontSize": "0.875rem"}}
                        >
                            No skills added.
                        </span>}
                    </div>
                </div>
            </div>
        </div>
    </div>;
}
