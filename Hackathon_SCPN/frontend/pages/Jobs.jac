cl import from react { useState, useEffect }
cl import from "@jac-client/utils" { jacIsLoggedIn, Navigate }

walker get_profile {}

walker fetch_jobs {
    has role_filter: str = "";
}

cl def Jobs()  -> any {
    if not jacIsLoggedIn() {
        return <Navigate to="/login" />;
    }

    [jobs, setJobs] = useState([]);
    [roleFilter, setRoleFilter] = useState("");
    [loading, setLoading] = useState(False);
    [initialized, setInitialized] = useState(False);

    # Clean and parse job data from backend
    def processJobs(jobsData: any) -> None {
        try {
            if not jobsData {
                setJobs([]);
                return;
            }

            # Handle string (needs parsing) or already parsed array
            # Check if it has replace method (string)
            if jobsData.replace {
                clean = jobsData.replace("```json", "").replace("```", "").trim();
                parsed = JSON.parse(clean);
                setJobs(parsed);
            } else {
                setJobs(jobsData);
            }
        } except parseErr {
            console.error("Error processing jobs:", parseErr);
            setJobs([]);
        }
    }

    # Core search function
    async def performSearch(role: str) -> None {
        if loading {
            return;
        }

        setLoading(True);
        setJobs([]);

        try {
            res = await root spawn fetch_jobs(role_filter=role);

            if res.reports and res.reports.length > 0 {
                processJobs(res.reports[0]);
            } else {
                setJobs([]);
            }
        } except ex {
            console.error("Error fetching jobs:", ex);
            setJobs([]);
        }

        setLoading(False);
    }

    # Handler for manual search button
    # Handler for manual search button
    def handleManualSearch()  -> None {
        performSearch(roleFilter);
    }

    # Initialize on mount: load profile and auto-search with target role
    useEffect(
        lambda   -> None{ if not initialized {
            async def init()  -> None {
                try {
                    res = await root spawn get_profile();

                    if not (res.reports and res.reports.length > 0) {
                        setInitialized(True);
                        return;
                    }

                    profile = res.reports[0];
                    targetRole = profile["target_role"] or "";

                    # Pre-fill role filter with target role and auto-search
                    setRoleFilter(targetRole);
                    
                    if targetRole {
                        setTimeout(
                            lambda   -> None{ performSearch(targetRole);} , 300
                        );
                    }

                    setInitialized(True);
                } except loadError {
                    console.error("Error initializing jobs:", loadError);
                    setInitialized(True);
                }
            }
            init();
        }} ,
        [initialized]
    );

    return <div
        className="container"
        style={{"maxWidth": "1200px", "padding": "2rem 1rem"}}
    >
        <h2
            className="mb-8"
            style={{
                "fontSize": "1.8rem",
                "fontWeight": "700",
                "color": "var(--foreground)"
            }}
        >
            Job Market Suggestions
        </h2>
        <div
            style={{"display": "flex", "gap": "1rem", "marginBottom": "2rem"}}
        >
            <input
                type="text"
                value={roleFilter}
                onChange={lambda  e: any  -> None{ setRoleFilter(e.target.value);} }
                placeholder="Enter role to search for jobs..."
                className="form-input"
                style={{"flex": 1}}
            />
            <button
                onClick={handleManualSearch}
                disabled={loading}
                className="btn btn-primary"
            >
                {loading and "Searching..."}{not loading and "Search"}
            </button>
        </div>
        {loading
        and <div
            style={{
                "textAlign": "center",
                "padding": "3rem",
                "color": "var(--muted-foreground)"
            }}
        >
            <div
                className="animate-fade-in"
                style={{"fontSize": "1.125rem"}}
            >
                Finding the best jobs for you...
            </div>
        </div>}
        {not loading
        and jobs.length == 0
        and <div
            style={{
                "textAlign": "center",
                "padding": "3rem",
                "color": "var(--muted-foreground)",
                "background": "var(--secondary)",
                "borderRadius": "var(--radius-md)",
                "border": "1px solid var(--border)"
            }}
        >
            <div
                style={{
                    "fontSize": "1.125rem",
                    "marginBottom": "0.5rem",
                    "fontWeight": "500"
                }}
            >
                No jobs found
            </div>
            <div
                style={{"fontSize": "0.875rem"}}
            >
                {roleFilter and "Try a different role or click Search"}{not roleFilter
                and "Enter a role and click Search to find jobs"}
            </div>
        </div>}
        <div
            className="grid-dashboard"
            style={{"gridTemplateColumns": "repeat(auto-fill, minmax(300px, 1fr))"}}
        >
            {jobs.map(
                lambda  j: any  -> any{ return <div className="card">
                    <div
                        className="flex-between"
                        style={{
                            "alignItems": "flex-start",
                            "marginBottom": "0.5rem",
                            "gap": "1rem"
                        }}
                    >
                        <h3
                            style={{
                                "margin": 0,
                                "fontSize": "1.25rem",
                                "color": "var(--card-foreground)",
                                "fontWeight": "600",
                                "lineHeight": "1.4"
                            }}
                        >
                            {j["title"]}
                        </h3>
                        {j["match_score"]
                        and <span
                            className="badge"
                            style={{
                                "background": "rgba(99, 102, 241, 0.15)",
                                "color": "#818cf8",
                                "border": "1px solid rgba(99, 102, 241, 0.3)",
                                "flexShrink": "0",
                                "whiteSpace": "nowrap",
                                "fontSize": "0.85rem"
                            }}
                        >
                            {j["match_score"]}% Match
                        </span>}
                    </div>
                    <p
                        style={{
                            "color": "var(--muted-foreground)",
                            "margin": 0,
                            "fontSize": "1rem"
                        }}
                    >
                        {j["company"]}
                    </p>
                </div>; }
            )}
        </div>
    </div>;
}
