cl import from react { useState, useEffect }
cl import from "@jac-client/utils" { jacIsLoggedIn, Navigate }

walker get_all_courses {}

cl def Courses() -> any {
    if not jacIsLoggedIn() {
        return <Navigate to="/login" />;
    }
    
    let [courses, setCourses] = useState([]);
    let [loading, setLoading] = useState(True);
    let [filterText, setFilterText] = useState("");
    
    # Load courses on mount
    useEffect(lambda -> None {
        async def loadCourses() -> None {
            setLoading(True);
            try {
                let res = await root spawn get_all_courses();
                if res.reports and res.reports.length > 0 {
                    setCourses(res.reports[0]);
                }
            } except err {
                console.error("Error loading courses:", err);
            }
            setLoading(False);
        }
        
        loadCourses();
    }, []);
    
    # Filter courses based on search text
    def getFilteredCourses() -> any {
        if not filterText {
            return courses;
        }
        
        let lower = filterText.toLowerCase();
        return courses.filter(lambda c: any -> bool {
            return c["title"].toLowerCase().includes(lower);
        });
    }
    
    let filteredCourses = getFilteredCourses();
    
    return <div style={{"maxWidth": "1200px", "margin": "0 auto", "padding": "0 1rem"}}>
        <h2>📚 Learning Resources</h2>
        <p style={{"color": "#6b7280", "marginBottom": "1.5rem"}}>
            Curated courses to help you build skills for your career goals.
        </p>
        
        <div style={{"marginBottom": "2rem"}}>
            <input
                type="text"
                value={filterText}
                onChange={lambda e: any -> None { setFilterText(e.target.value); }}
                placeholder="Search courses by title..."
                style={{
                    "width": "100%",
                    "padding": "0.75rem",
                    "border": "1px solid #d1d5db",
                    "borderRadius": "6px",
                    "fontSize": "1rem"
                }}
            />
        </div>
        
        {loading and <div style={{"textAlign": "center", "padding": "3rem", "color": "#6b7280"}}>
            Loading courses...
        </div>}
        
        {not loading and filteredCourses.length == 0 and <div style={{
            "textAlign": "center",
            "padding": "3rem",
            "color": "#6b7280",
            "background": "#f9fafb",
            "borderRadius": "8px",
            "border": "1px solid #e5e7eb"
        }}>
            <div style={{"fontSize": "1.125rem"}}>No courses found</div>
            <div style={{"fontSize": "0.875rem", "marginTop": "0.5rem"}}>
                {filterText and "Try a different search term"}
                {not filterText and "No courses available"}
            </div>
        </div>}
        
        <div style={{"display": "grid", "gap": "1.5rem", "gridTemplateColumns": "repeat(auto-fill, minmax(350px, 1fr))"}}>
            {filteredCourses.map(lambda course: any -> any {
                return <div style={{
                    "background": "white",
                    "padding": "1.5rem",
                    "borderRadius": "8px",
                    "border": "1px solid #e5e7eb",
                    "boxShadow": "0 1px 3px 0 rgba(0, 0, 0, 0.1)",
                    "transition": "transform 0.2s, box-shadow 0.2s",
                    "hover": {
                        "transform": "translateY(-2px)",
                        "boxShadow": "0 4px 6px 0 rgba(0, 0, 0, 0.1)"
                    }
                }}>
                    <h3 style={{
                        "margin": "0 0 0.75rem 0",
                        "fontSize": "1.125rem",
                        "color": "#111827",
                        "fontWeight": "600",
                        "lineHeight": "1.4"
                    }}>
                        {course["title"]}
                    </h3>
                    
                    {course["duration"] and <div style={{
                        "display": "flex",
                        "alignItems": "center",
                        "gap": "0.5rem",
                        "color": "#6b7280",
                        "fontSize": "0.875rem",
                        "marginBottom": "1rem"
                    }}>
                        <span>⏱️</span>
                        <span>{course["duration"]}</span>
                    </div>}
                    
                    {course["url"] and <a
                        href={course["url"]}
                        target="_blank"
                        rel="noopener noreferrer"
                        style={{
                            "display": "inline-block",
                            "padding": "0.5rem 1rem",
                            "background": "#2563eb",
                            "color": "white",
                            "textDecoration": "none",
                            "borderRadius": "6px",
                            "fontSize": "0.875rem",
                            "fontWeight": "500",
                            "transition": "background 0.2s"
                        }}
                    >
                        View Course →
                    </a>}
                </div>;
            })}
        </div>
    </div>;
}
