cl import from react {
    useState,
    useEffect
}
cl import from "@jac-client/utils" {
    useLocation,
    jacIsLoggedIn,
    Navigate
}

walker generate_roadmap {
    has target_role: str;
}

walker get_profile {}
walker get_all_roles {}

cl def CareerPath() -> any {
    if not jacIsLoggedIn() { return <Navigate to="/login" />; }
    
    let [role, setRole] = useState("");
    let [availableRoles, setAvailableRoles] = useState([]);
    let [roadmap, setRoadmap] = useState(None);
    let [loading, setLoading] = useState(False);
    let [error, setError] = useState("");
    let location = useLocation();

    def safeParse(data: any, label: str) -> any {
        if not data { return []; }
        try {
            if data.replace {
                let clean = data.replace("```json", "").replace("```", "").trim();
                return JSON.parse(clean);
            }
            return data;
        } except err {
            # If parsing fails, return the cleaned string
            if data.replace {
                return data.replace("```json", "").replace("```", "").trim();
            }
            return data;
        }
    }

    def renderContent(content: any) -> any {
        if not content { return null; }
        
        # Handle Object Content (parsed JSON objects)
        if content.strengths or content.gaps or content.recommendation {
            # Strategy object
            return <div style={{"display": "flex", "flexDirection": "column", "gap": "1.5rem"}}>
                {content.strengths and Array.isArray(content.strengths) and content.strengths.length > 0 and <div>
                    <h4 style={{"fontSize": "1.1rem", "fontWeight": "bold", "marginBottom": "0.75rem", "color": "#059669"}}>✓ Strengths</h4>
                    <div style={{"display": "flex", "flexDirection": "column", "gap": "0.5rem", "paddingLeft": "0.5rem"}}>
                        {content.strengths.map(lambda item: str, i: int -> any {
                            return <div key={i} style={{"display": "flex", "gap": "0.5rem", "alignItems": "flex-start"}}>
                                <span style={{"color": "#059669", "fontWeight": "bold"}}>●</span>
                                <span style={{"color": "#374151", "lineHeight": "1.6"}}>{item}</span>
                            </div>;
                        })}
                    </div>
                </div>}
                {content.gaps and Array.isArray(content.gaps) and content.gaps.length > 0 and <div>
                    <h4 style={{"fontSize": "1.1rem", "fontWeight": "bold", "marginBottom": "0.75rem", "color": "#dc2626"}}>⚠ Gaps</h4>
                    <div style={{"display": "flex", "flexDirection": "column", "gap": "0.5rem", "paddingLeft": "0.5rem"}}>
                        {content.gaps.map(lambda item: str, i: int -> any {
                            return <div key={i} style={{"display": "flex", "gap": "0.5rem", "alignItems": "flex-start"}}>
                                <span style={{"color": "#dc2626", "fontWeight": "bold"}}>●</span>
                                <span style={{"color": "#374151", "lineHeight": "1.6"}}>{item}</span>
                            </div>;
                        })}
                    </div>
                </div>}
                {content.recommendation and <div>
                    <h4 style={{"fontSize": "1.1rem", "fontWeight": "bold", "marginBottom": "0.75rem", "color": "#2563eb"}}>→ Recommendation</h4>
                    <p style={{"color": "#374151", "lineHeight": "1.6", "paddingLeft": "0.5rem"}}>{content.recommendation}</p>
                </div>}
            </div>;
        }

        if content.demand or content.salary_range or content.top_companies {
            # Market object
            let demandColor = "#6b7280";
            if content.demand == "High" {
                demandColor = "#059669";
            } elif content.demand == "Medium" {
                demandColor = "#d97706";
            }
            
            return <div style={{"display": "flex", "flexDirection": "column", "gap": "1.5rem"}}>
                {content.demand and <div>
                    <span style={{"fontWeight": "bold", "color": "#1f2937"}}>Market Demand: </span>
                    <span style={{"color": demandColor, "fontWeight": "600", "fontSize": "1.1rem"}}>{content.demand}</span>
                </div>}
                {content.salary_range and <div>
                    <span style={{"fontWeight": "bold", "color": "#1f2937"}}>Salary Range: </span>
                    <span style={{"color": "#059669", "fontWeight": "600", "fontSize": "1.1rem"}}>{content.salary_range}</span>
                </div>}
                {content.top_companies and Array.isArray(content.top_companies) and content.top_companies.length > 0 and <div>
                    <h4 style={{"fontSize": "1.1rem", "fontWeight": "bold", "marginBottom": "0.75rem", "color": "#2563eb"}}>Top Hiring Companies</h4>
                    <div style={{"display": "flex", "flexWrap": "wrap", "gap": "0.75rem"}}>
                        {content.top_companies.map(lambda company: str, i: int -> any {
                            return <span key={i} style={{"background": "#dbeafe", "color": "#1e40af", "padding": "0.5rem 1rem", "borderRadius": "9999px", "fontSize": "0.9rem", "fontWeight": "500"}}>{company}</span>;
                        })}
                    </div>
                </div>}
            </div>;
        }

        if content.weeks and Array.isArray(content.weeks) {
            # Learning plan object
            return <div style={{"display": "grid", "gap": "1.5rem"}}>
                {content.weeks.map(lambda week: any, i: int -> any {
                    return <div key={i} style={{"background": "#fef3c7", "padding": "1.5rem", "borderRadius": "8px", "borderLeft": "4px solid #d97706"}}>
                        <div style={{"fontWeight": "bold", "color": "#92400e", "fontSize": "1.1rem", "marginBottom": "0.5rem"}}>
                            Week {week.week or (i + 1)}
                        </div>
                        {week.focus and <div style={{"color": "#78350f", "fontWeight": "600", "marginBottom": "0.75rem"}}>{week.focus}</div>}
                        {week.resources and Array.isArray(week.resources) and week.resources.length > 0 and <div style={{"marginTop": "0.75rem"}}>
                            <div style={{"fontSize": "0.9rem", "fontWeight": "600", "color": "#92400e", "marginBottom": "0.5rem"}}>Resources:</div>
                            <div style={{"display": "flex", "flexDirection": "column", "gap": "0.25rem", "paddingLeft": "0.5rem"}}>
                                {week.resources.map(lambda res: str, j: int -> any {
                                    return <div key={j} style={{"fontSize": "0.9rem", "color": "#78350f"}}>• {res}</div>;
                                })}
                            </div>
                        </div>}
                    </div>;
                })}
            </div>;
        }
        
        # Handle String Content (Markdown-like)
        if content.replace {
            let lines = content.split("\n");
            return <div style={{"display": "flex", "flexDirection": "column", "gap": "0.5rem"}}>
                {lines.map(lambda line: str, i: int -> any {
                    let cleanLine = line.trim();
                    if not cleanLine { return null; }
                    
                    # Headers
                    if cleanLine.startsWith("### ") {
                        return <h4 key={i} style={{"fontSize": "1.1rem", "fontWeight": "bold", "marginTop": "1rem", "color": "#374151"}}>{cleanLine.substring(4)}</h4>;
                    }
                    if cleanLine.startsWith("## ") {
                        return <h3 key={i} style={{"fontSize": "1.2rem", "fontWeight": "bold", "marginTop": "1.2rem", "color": "#1f2937"}}>{cleanLine.substring(3)}</h3>;
                    }

                    # List items
                    if cleanLine.startsWith("* ") or cleanLine.startsWith("- ") {
                        let text = cleanLine.substring(2);
                        let parts = text.split("**");
                        return <div key={i} style={{"display": "flex", "gap": "0.5rem", "alignItems": "flex-start", "paddingLeft": "0.5rem"}}>
                            <span style={{"color": "#3b82f6", "marginTop": "0.4rem", "fontSize": "0.8rem"}}>●</span>
                            <span style={{"lineHeight": "1.6", "color": "#4b5563"}}>
                                {parts.map(lambda p: str, j: int -> any {
                                    if j % 2 == 1 {
                                        return <strong key={j} style={{"color": "#1f2937"}}>{p}</strong>;
                                    }
                                    return <span>{p}</span>;
                                })}
                            </span>
                        </div>;
                    }

                    # Regular paragraphs
                    let parts = cleanLine.split("**");
                    return <p key={i} style={{"lineHeight": "1.6", "color": "#374151", "margin": "0"}}>
                        {parts.map(lambda p: str, j: int -> any {
                            if j % 2 == 1 {
                                return <strong key={j} style={{"color": "#1f2937"}}>{p}</strong>;
                            }
                            return <span>{p}</span>;
                        })}
                    </p>;
                })}
            </div>;
        }
        
        # Handle Array Content (Generic array of items)
        if Array.isArray(content) {
            return <div style={{"display": "grid", "gap": "1rem", "gridTemplateColumns": "repeat(auto-fit, minmax(300px, 1fr))"}}>
                {content.map(lambda item: any, i: int -> any {
                    let desc = item["description"] or item["details"];
                    if not desc and item["actions"] and Array.isArray(item["actions"]) {
                        desc = item["actions"].join(", ");
                    }
                    if not desc { desc = item; }

                    return <div key={i} style={{"background": "#f8fafc", "padding": "1.5rem", "borderRadius": "8px", "border": "1px solid #e2e8f0"}}>
                        <div style={{"fontWeight": "bold", "color": "#1e293b", "marginBottom": "0.5rem", "fontSize": "1.1rem"}}>
                            {item["title"] or item["week"] or item["area"] or "Point"}
                        </div>
                        {item["topic"] and <div style={{"fontWeight": "600", "color": "#4b5563", "marginBottom": "0.5rem"}}>{item["topic"]}</div>}
                        <div style={{"color": "#475569", "lineHeight": "1.6"}}>
                            {desc}
                        </div>
                    </div>;
                })}
            </div>;
        }

        # Fallback - show raw JSON
        return <div style={{"whiteSpace": "pre-wrap", "background": "#f3f4f6", "padding": "1rem", "borderRadius": "6px", "fontSize": "0.9rem", "color": "#374151", "overflow": "auto"}}>{JSON.stringify(content, null, 2)}</div>;
    }

    def renderSection(title: str, content: any, color: str) -> any {
        if not content { return null; }
        # Filter out short/useless strings
        if content.replace and content.length < 20 { return null; }
        if Array.isArray(content) and content.length == 0 { return null; }

        let sectionId = title.replace(" ", "").toLowerCase();

        return <div id={sectionId} style={{"background": "white", "padding": "2rem", "borderRadius": "12px", "boxShadow": "0 4px 6px -1px rgba(0, 0, 0, 0.1)", "borderTop": "4px solid " + color}}>
            <h3 style={{"color": color, "fontSize": "1.5rem", "marginBottom": "1.5rem", "paddingBottom": "0.5rem", "borderBottom": "1px solid #f3f4f6"}}>{title}</h3>
            {renderContent(content)}
        </div>;
    }

    async def processResponse(report: any) -> None {
        let newRoadmap = {};
        
        newRoadmap["target_role"] = report["target_role"];
        
        # Helper to parse and extract data from LLM responses
        def extractData(data: any) -> any {
            if not data { return []; }
            
            # Parse if it's a string
            let parsed = safeParse(data, "extract");
            
            # If it's already a clean object/array, return it
            if parsed and (Array.isArray(parsed) or (parsed.strengths or parsed.demand or parsed.weeks or parsed.gaps)) {
                return parsed;
            }
            
            # Otherwise return the parsed value
            return parsed;
        }

        newRoadmap["strategy"] = extractData(report["strategy"]);
        newRoadmap["market"] = extractData(report["market"]);
        newRoadmap["plan"] = extractData(report["plan"]);
        
        if "last_gaps_analysis" in report {
            newRoadmap["gaps"] = extractData(report["last_gaps_analysis"]);
        } elif "gaps" in report {
            newRoadmap["gaps"] = extractData(report["gaps"]);
        }

        setRoadmap(newRoadmap);
    }

    async def generate() -> None {
        if not role { return; }
        setLoading(True);
        setError("");
        setRoadmap(None);
        
        try {
            let res = await root spawn generate_roadmap(target_role=role);

            if res.reports and res.reports.length > 0 {
                await processResponse(res.reports[0]);
            } else {
                setError("No data received from AI. Please try again.");
            }
        } except genError {
            console.error("Generation error:", genError);
            setError("An error occurred while generating the roadmap.");
        }
        
        setLoading(False);
    }

    useEffect(lambda -> None {
        async def init() -> None {
            # Fetch available roles
            try {
                let rolesRes = await root spawn get_all_roles();
                if rolesRes.reports and rolesRes.reports.length > 0 {
                    setAvailableRoles(rolesRes.reports[0]);
                }
            } except err {
                console.error("Error fetching roles:", err);
            }

            if location.state and location.state["role"] {
                setRole(location.state["role"]);
                if location.state["run"] {
                    generate();
                    return;
                }
            }

            # Scroll to learning plan if requested
            if location.state and location.state["scrollTo"] == "learningPlan" {
                setTimeout(lambda -> None {
                    let element = document.getElementById("learningplan");
                    if element {
                        element.scrollIntoView({"behavior": "smooth", "block": "start"});
                    }
                }, 1000);
            }

            try {
                let res = await root spawn get_profile();
                if res.reports and res.reports.length > 0 {
                    let p = res.reports[0];
                    if p["target_role"] { setRole(p["target_role"]); }
                    
                    let savedRoadmap = {};
                    let hasData = False;

                    if p["last_strategy"] { 
                        savedRoadmap["strategy"] = p["last_strategy"]; 
                        savedRoadmap["target_role"] = p["target_role"];
                        hasData = True; 
                    }
                    if p["last_market"] { 
                        savedRoadmap["market"] = p["last_market"]; 
                        hasData = True; 
                    }
                    if p["last_roadmap_plan"] { 
                        savedRoadmap["plan"] = p["last_roadmap_plan"]; 
                        hasData = True; 
                    }
                    if p["last_gaps_analysis"] { 
                        savedRoadmap["last_gaps_analysis"] = p["last_gaps_analysis"]; 
                        hasData = True; 
                    }

                    if hasData {
                        await processResponse(savedRoadmap);
                    }
                }
            } except loadError {
                console.error("Error loading profile:", loadError);
            }
        }
        init();
    }, []);

    return <div style={{"maxWidth": "1200px", "margin": "0 auto", "padding": "2rem", "fontFamily": "sans-serif"}}>
        <h2 style={{"color": "#111827", "marginBottom": "2rem", "fontSize": "2rem", "fontWeight": "700", "textAlign": "center"}}>AI Career Roadmap</h2>
        
        <div style={{"background": "white", "padding": "2rem", "borderRadius": "12px", "boxShadow": "0 4px 6px -1px rgba(0, 0, 0, 0.1)", "marginBottom": "3rem", "maxWidth": "800px", "margin": "0 auto 3rem auto"}}>
            <div style={{"display": "flex", "gap": "1rem", "flexWrap": "wrap"}}>
                <div style={{"flex": 1}}>
                    <input 
                        list="career-roles-list"
                        type="text" 
                        placeholder="Enter Target Role (e.g. Senior Python Developer)" 
                        value={role} 
                        onChange={lambda e: any -> None { setRole(e.target.value); }} 
                        style={{"padding": "1rem", "border": "1px solid #d1d5db", "borderRadius": "8px", "fontSize": "1rem", "width": "100%"}} 
                    />
                    <datalist id="career-roles-list">
                        {availableRoles.map(lambda r: any, i: int -> any {
                            return <option key={i} value={r.title}>{r.description}</option>;
                        })}
                    </datalist>
                </div>
                <button 
                    onClick={generate} 
                    disabled={loading}
                    style={{
                        "padding": "1rem 2rem", 
                        "background": "#2563eb" if not loading else "#93c5fd", 
                        "color": "white", 
                        "border": "none", 
                        "borderRadius": "8px", 
                        "cursor": "pointer" if not loading else "default",
                        "fontWeight": "600",
                        "fontSize": "1rem",
                        "transition": "background 0.2s"
                    }}
                >
                    { "Generating Plan..." if loading else "Generate Roadmap" }
                </button>
            </div>
            {error and <div style={{"color": "#dc2626", "marginTop": "1rem", "fontWeight": "500", "textAlign": "center"}}>{error}</div>}
        </div>

        {loading and <div style={{"textAlign": "center", "padding": "4rem", "color": "#6b7280"}}>
            <div style={{"fontSize": "1.5rem", "marginBottom": "1rem", "fontWeight": "500"}}>Analyzing your profile and market data...</div>
            <div style={{"fontSize": "1.1rem"}}>This may take a few seconds.</div>
        </div>}

        {not loading and roadmap and <div style={{"display": "grid", "gap": "2rem"}}>
            {renderSection("Strategic Analysis", roadmap["strategy"], "#1e40af")}
            {renderSection("Market Insights", roadmap["market"], "#059669")}
            {renderSection("Learning Plan", roadmap["plan"], "#d97706")}
            {renderSection("Gaps Analysis", roadmap["gaps"], "#dc2626")}
        </div>}
    </div>;
}