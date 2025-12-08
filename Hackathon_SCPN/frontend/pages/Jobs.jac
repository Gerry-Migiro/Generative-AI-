cl import from react { useState, useEffect }
cl import from "@jac-client/utils" { jacIsLoggedIn, Navigate }

walker get_profile {}

walker fetch_jobs {
    has role_filter: str = "";
}

cl def Jobs() -> any {
    if not jacIsLoggedIn() {
        return <Navigate to="/login" />;
    }
    
    let [jobs, setJobs] = useState([]);
    let [roleFilter, setRoleFilter] = useState("");
    let [loading, setLoading] = useState(False);
    let [initialized, setInitialized] = useState(False);

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
                let clean = jobsData.replace("```json", "").replace("```", "").trim();
                let parsed = JSON.parse(clean);
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
        if loading { return; }
        
        setLoading(True);
        setJobs([]);
        
        try {
            let res = await root spawn fetch_jobs(role_filter=role);
            
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
    def handleManualSearch() -> None {
        performSearch(roleFilter);
    }

    # Initialize on mount: load profile, determine if we should load saved jobs or search
    useEffect(lambda -> None {
        if not initialized {
            async def init() -> None {
                try {
                    let res = await root spawn get_profile();
                    
                    if not (res.reports and res.reports.length > 0) {
                        setInitialized(True);
                        return;
                    }
                    
                    let profile = res.reports[0];
                    let targetRole = profile["target_role"] or "";
                    let savedFilter = profile["jobs_role_filter"] or "";
                    let savedJobsStr = profile["last_jobs"] or "[]";
                    
                    # Pre-fill role filter input with current target role
                    setRoleFilter(targetRole);
                    
                    # Check if we have valid saved jobs
                    let hasSavedJobs = False;
                    try {
                        let cleanStr = savedJobsStr.replace("```json", "").replace("```", "").trim();
                        let parsed = JSON.parse(cleanStr);
                        hasSavedJobs = Array.isArray(parsed) and parsed.length > 0;
                    } except err {
                        hasSavedJobs = False;
                    }
                    
                    # Decision logic:
                    # 1. If no saved jobs AND we have target role -> auto-search
                    # 2. If saved jobs AND saved filter matches target role -> load saved
                    # 3. If saved jobs AND saved filter doesn't match -> auto-search
                    # 4. Otherwise -> do nothing (wait for manual search)
                    
                    if not hasSavedJobs {
                        # No saved jobs - auto-search if we have a target role
                        if targetRole {
                            setTimeout(lambda -> None {
                                performSearch(targetRole);
                            }, 300);
                        }
                    } else {
                        # Have saved jobs - check if role changed
                        if savedFilter == targetRole {
                            # Role unchanged - load saved jobs
                            processJobs(savedJobsStr);
                        } else {
                            # Role changed - auto-search with new role
                            if targetRole {
                                setTimeout(lambda -> None {
                                    performSearch(targetRole);
                                }, 300);
                            } else {
                                # No target role but have old data - still show it
                                processJobs(savedJobsStr);
                            }
                        }
                    }
                    
                    setInitialized(True);
                } except loadError {
                    console.error("Error initializing jobs:", loadError);
                    setInitialized(True);
                }
            }
            
            init();
        }
    }, [initialized]);

    return <div style={{"maxWidth": "1200px", "margin": "0 auto", "padding": "0 1rem"}}>
        <h2>Job Market Suggestions</h2>
        
        <div style={{"display": "flex", "gap": "1rem", "marginBottom": "2rem"}}>
            <input
                type="text"
                value={roleFilter}
                onChange={lambda e: any -> None { setRoleFilter(e.target.value); }}
                placeholder="Enter role to search for jobs..."
                style={{
                    "flex": 1,
                    "padding": "0.75rem",
                    "border": "1px solid #d1d5db",
                    "borderRadius": "4px",
                    "fontSize": "1rem"
                }}
            />
            <button
                onClick={handleManualSearch}
                disabled={loading}
                style={{
                    "padding": "0.75rem 1.5rem",
                    "background": "#2563eb",
                    "color": "white",
                    "border": "none",
                    "borderRadius": "4px",
                    "cursor": "pointer",
                    "fontSize": "1rem",
                    "fontWeight": "500"
                }}
            >
                {loading and "Searching..."}
                {not loading and "Search"}
            </button>
        </div>

        {loading and <div style={{"textAlign": "center", "padding": "3rem", "color": "#6b7280"}}>
            <div style={{"fontSize": "1.125rem"}}>Finding the best jobs for you...</div>
        </div>}

        {not loading and jobs.length == 0 and <div style={{
            "textAlign": "center", 
            "padding": "3rem", 
            "color": "#6b7280",
            "background": "#f9fafb",
            "borderRadius": "8px",
            "border": "1px solid #e5e7eb"
        }}>
            <div style={{"fontSize": "1.125rem", "marginBottom": "0.5rem"}}>No jobs found</div>
            <div style={{"fontSize": "0.875rem"}}>
                {roleFilter and "Try a different role or click Search"}
                {not roleFilter and "Enter a role and click Search to find jobs"}
            </div>
        </div>}

        <div style={{"display": "grid", "gap": "1rem"}}>
            {jobs.map(lambda j: any -> any {
                return <div style={{
                    "background": "white",
                    "padding": "1.5rem",
                    "borderRadius": "8px",
                    "border": "1px solid #e5e7eb",
                    "boxShadow": "0 1px 2px 0 rgba(0, 0, 0, 0.05)"
                }}>
                    <div style={{
                        "display": "flex", 
                        "justifyContent": "space-between", 
                        "alignItems": "flex-start",
                        "marginBottom": "0.5rem"
                    }}>
                        <h3 style={{"margin": 0, "fontSize": "1.25rem", "color": "#111827"}}>
                            {j["title"]}
                        </h3>
                        {j["match_score"] and <span style={{
                            "background": "#dbeafe",
                            "color": "#1e40af",
                            "padding": "0.25rem 0.75rem",
                            "borderRadius": "9999px",
                            "fontSize": "0.875rem",
                            "fontWeight": "600"
                        }}>
                            {j["match_score"]}% Match
                        </span>}
                    </div>
                    <p style={{"color": "#6b7280", "margin": 0, "fontSize": "1rem"}}>
                        {j["company"]}
                    </p>
                </div>;
            })}
        </div>
    </div>;
}
