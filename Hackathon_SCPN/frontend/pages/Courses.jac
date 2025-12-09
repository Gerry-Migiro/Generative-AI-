cl import from react { useState, useEffect }
cl import from "@jac-client/utils" { jacIsLoggedIn, Navigate }

walker get_recommended_courses {}

cl def Courses()  -> any {
    if not jacIsLoggedIn() {
        return <Navigate to="/login" />;
    }

    [courses, setCourses] = useState([]);
    [loading, setLoading] = useState(True);
    [filterText, setFilterText] = useState("");

    # Load personalized courses on mount
    useEffect(
        lambda   -> None{ async def loadCourses()  -> None {
            setLoading(True);
            try {
                res = await root spawn get_recommended_courses();
                if res.reports and res.reports.length > 0 {
                    setCourses(res.reports[0]);
                }
            } except err {
                console.error("Error loading courses:", err);
            }
            setLoading(False);
        } loadCourses();} ,
        []
    );

    # Filter courses based on search text
    def getFilteredCourses()  -> any {
        if not filterText {
            return courses;
        }

        lower = filterText.toLowerCase();
        return courses.filter(
            lambda  c: any  -> bool{ return c["title"].toLowerCase().includes(lower); }
        );
    }

    filteredCourses = getFilteredCourses();

    return <div
        className="container"
        style={{"maxWidth": "1200px", "padding": "2rem 1rem"}}
    >
        <h2
            className="mb-4"
            style={{
                "fontSize": "1.8rem",
                "fontWeight": "700",
                "color": "var(--foreground)"
            }}
        >
            📚 Recommended Learning Resources
        </h2>
        <p
            className="text-sub"
            style={{"marginBottom": "1.5rem"}}
        >
            Personalized courses based on your skill gaps and career goals.
        </p>
        <div
            style={{"marginBottom": "2rem"}}
        >
            <input
                type="text"
                value={filterText}
                onChange={lambda  e: any  -> None{ setFilterText(e.target.value);} }
                placeholder="Search courses by title..."
                className="form-input"
            />
        </div>
        {loading
        and <div
            style={{
                "textAlign": "center",
                "padding": "3rem",
                "color": "var(--muted-foreground)"
            }}
        >
            <div className="animate-fade-in">
                Loading courses...
            </div>
        </div>}
        {not loading
        and filteredCourses.length == 0
        and <div
            className="card"
            style={{
                "textAlign": "center",
                "padding": "3rem",
                "background": "var(--secondary)"
            }}
        >
            <div
                style={{"fontSize": "1.125rem", "fontWeight": "500"}}
            >
                No courses found
            </div>
            <div
                style={{
                    "fontSize": "0.875rem",
                    "marginTop": "0.5rem",
                    "color": "var(--muted-foreground)"
                }}
            >
                {filterText and "Try a different search term"}{not filterText
                and "No courses available"}
            </div>
        </div>}
        <div
            className="grid-dashboard"
            style={{"gridTemplateColumns": "repeat(auto-fill, minmax(350px, 1fr))"}}
        >
            {filteredCourses.map(
                lambda  course: any  -> any{ return <div
                    className="card"
                    style={{"transition": "transform 0.2s, box-shadow 0.2s",}}
                >
                    <h3
                        style={{
                            "margin": "0 0 0.75rem 0",
                            "fontSize": "1.125rem",
                            "color": "var(--card-foreground)",
                            "fontWeight": "600",
                            "lineHeight": "1.4"
                        }}
                    >
                        {course["title"]}
                    </h3>
                    {course["duration"]
                    and <div
                        style={{
                            "display": "flex",
                            "alignItems": "center",
                            "gap": "0.5rem",
                            "color": "var(--muted-foreground)",
                            "fontSize": "0.875rem",
                            "marginBottom": "1rem"
                        }}
                    >
                        <span>
                            ⏱️
                        </span>
                        <span>
                            {course["duration"]}
                        </span>
                    </div>}
                    {course["url"]
                    and <a
                        href={course["url"]}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="btn btn-primary"
                        style={{
                            "display": "inline-block",
                            "padding": "0.5rem 1rem",
                            "textDecoration": "none",
                            "fontSize": "0.875rem"
                        }}
                    >
                        View Course →
                    </a>}
                </div>; }
            )}
        </div>
    </div>;
}
