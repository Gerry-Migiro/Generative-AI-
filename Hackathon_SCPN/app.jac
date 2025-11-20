
# Pages
cl import from react {useState, useEffect}
cl import from "react-icons/fa" {FaBrain, FaLightbulb, FaChartBar}

cl {
    def FeatureCard(props: any) -> any {
        return <div style={{
            "padding": "24px",
            "border": "1px solid #e5e7eb",
            "borderRadius": "12px",
            "background": "#ffffff",
            "boxShadow": "0 1px 2px 0 rgba(0, 0, 0, 0.05)",
            "transition": "box-shadow 0.3s"
        }}>
            <div style={{
                "marginBottom": "12px",
                "fontSize": "30px",
                "color": "#3b82f6"
            }}>
                {props.icon}
            </div>
            <h3 style={{
                "fontSize": "20px",
                "fontWeight": "600",
                "marginBottom": "8px"
            }}>
                {props.title}
            </h3>
            <p style={{
                "color": "#6b7280",
                "fontSize": "14px"
            }}>
                {props.description}
            </p>
        </div>;
    }

    def app() -> any {
        return (
            <div>
                <section style={{
                    "paddingTop": "40px",
                    "paddingBottom": "80px",
                    "width": "100%"
                }}>
                    <div style={{
                        "maxWidth": "1280px",
                        "margin": "0 auto",
                        "display": "flex",
                        "flexDirection": "column",
                        "gap": "64px",
                        "padding": "0 16px"
                    }}>
                        <div style={{
                            "textAlign": "center",
                            "display": "flex",
                            "flexDirection": "column",
                            "gap": "16px"
                        }}>
                            <h2 style={{
                                "fontSize": "36px",
                                "fontWeight": "bold"
                            }}>
                                Features that guide your journey
                            </h2>
                            <p style={{
                                "color": "#6b7280",
                                "fontSize": "18px"
                            }}>
                                Explore intelligent tools designed to help you discover, plan, and grow in your career path.
                            </p>
                        </div>
                        <div style={{
                            "display": "grid",
                            "gridTemplateColumns": "repeat(auto-fit, minmax(250px, 1fr))",
                            "gap": "32px"
                        }}>
                            <FeatureCard 
                                icon={<FaBrain />}
                                title="AI-Powered Insights"
                                description="Personalized suggestions driven by graph-based reasoning."
                            />
                            <FeatureCard 
                                icon={<FaLightbulb />}
                                title="Skill Matching"
                                description="Instantly discover roles aligned with your strengths."
                            />
                            <FeatureCard 
                                icon={<FaChartBar />}
                                title="Progress Tracking"
                                description="Visualize your advancement through adaptive insights."
                            />
                        </div>
                        <div style={{
                            "display": "flex",
                            "justifyContent": "center",
                            "paddingTop": "16px"
                        }}>
                            <button
                                id="getStartedBtn"
                                style={{
                                    "padding": "12px 24px",
                                    "background": "#3b82f6",
                                    "color": "#ffffff",
                                    "border": "none",
                                    "borderRadius": "8px",
                                    "fontSize": "18px",
                                    "cursor": "pointer"
                                }}
                            >
                                Get Started
                            </button>
                        </div>
                    </div>
                </section>
            </div>
        );
    }
}
