cl import from react { useState, useEffect }

walker get_profile {}
walker get_all_roles {}
walker add_skill {
    has skill_name: str;
}

walker update_profile {
    has name: str = "";
    has interests: list = [];
    has goals: list = [];
    has target_role: str = "";
}

walker delete_skill {
    has skill_name: str;
}

walker parse_resume {
    has resume_text: str;
}

cl def Profile()  -> any {
    let [profile, setProfile] = useState(
        {"name": "", "interests": [], "goals": [], "skills": [], "target_role": ""}
    );
    let [availableRoles, setAvailableRoles] = useState([]);
    let [newSkill, setNewSkill] = useState("");
    let [newInterest, setNewInterest] = useState("");
    let [newGoal, setNewGoal] = useState("");
    let [message, setMessage] = useState("");
    let [loading, setLoading] = useState(False);
    let [resumeText, setResumeText] = useState("");
    let [parseLoading, setParseLoading] = useState(False);

    # Load profile on mount
    useEffect(
        lambda   -> None{ async def load()  -> None {
            setLoading(True);
            
            # Fetch available roles
            try {
                let rolesRes = await root spawn get_all_roles();
                if rolesRes.reports and rolesRes.reports.length > 0 {
                    setAvailableRoles(rolesRes.reports[0]);
                }
            } except err {
                console.error("Error fetching roles:", err);
            }
            
            let res = await root spawn get_profile();
            if res.reports and res.reports.length > 0 {
                let p = res.reports[0];
                if p {
                    setProfile(p);
                }
            }
            setLoading(False);
        } load();} ,
        []
    );

    # --- Skill Management (Immediate Graph Operations) ---
    async def handleAddSkill()  -> None {
        if not newSkill {
            return;
        }

        # Optimistic update
        let currentSkills = profile["skills"];
        let updatedSkills = currentSkills.concat([newSkill]);

        let newProfile = {
            "name": profile["name"],
            "interests": profile["interests"],
            "goals": profile["goals"],
            "skills": updatedSkills,
            "target_role": profile["target_role"]
        };
        setProfile(newProfile);

        # Backend call
        await root spawn add_skill(skill_name=newSkill);

        # Sync to be safe
        let res = await root spawn get_profile();
        if res.reports {
            setProfile(res.reports[0]);
        }

        setNewSkill("");
    }

    async def handleDeleteSkill(skillName: str) -> None {
        # Optimistic update
        let updatedSkills = profile["skills"].filter(
            lambda  s: str  -> bool{ return s != skillName; }
        );

        let newProfile = {
            "name": profile["name"],
            "interests": profile["interests"],
            "goals": profile["goals"],
            "skills": updatedSkills,
            "target_role": profile["target_role"]
        };
        setProfile(newProfile);

        # Backend call
        await root spawn delete_skill(skill_name=skillName);

        # Sync to be safe
        let res = await root spawn get_profile();
        if res.reports {
            setProfile(res.reports[0]);
        }
    }

    # --- Profile Fields Management (Batch Save) ---
    def handleUpdateField(key: str, value: any) -> None {
        let newProfile = {
            "name": profile["name"],
            "interests": profile["interests"],
            "goals": profile["goals"],
            "skills": profile["skills"],
            "target_role": profile["target_role"]
        };
        newProfile[key] = value;
        setProfile(newProfile);
    }

    def handleAddList(key: str, value: str, setter: any) -> None {
        if value {
            let currentList = profile[key];
            let updatedList = currentList.concat([value]);
            handleUpdateField(key, updatedList);
            setter("");
        }
    }

    def handleDeleteList(key: str, value: str) -> None {
        let updatedList = profile[key].filter(
            lambda  i: str  -> bool{ return i != value; }
        );
        handleUpdateField(key, updatedList);
    }

    async def handleSaveProfile()  -> None {
        setMessage("Saving...");
        await root spawn update_profile(
            name=profile["name"],
            interests=profile["interests"],
            goals=profile["goals"],
            target_role=profile["target_role"]
        );
        setMessage("Profile saved successfully!");
        setTimeout(lambda   -> None{ setMessage("");} , 3000);
    }

    # --- Resume Parsing ---
    async def handleResumeUpload()  -> None {
        if not resumeText {
            setMessage("Please paste your resume text first!");
            setTimeout(lambda   -> None{ setMessage("");} , 3000);
            return;
        }

        setParseLoading(True);
        setMessage("Parsing resume...");
        
        try {
            let res = await root spawn parse_resume(resume_text=resumeText);
            
            if res.reports and res.reports.length > 0 {
                let result = res.reports[0];
                
                # Refresh profile to show newly added skills
                let profileRes = await root spawn get_profile();
                if profileRes.reports {
                    setProfile(profileRes.reports[0]);
                }
                
                # Show success message with details
                let added_count = result["added_skills"].length;
                let skipped_count = result["skipped_skills"].length;
                
                setMessage(
                    f"Resume parsed! Added {added_count} new skills, skipped {skipped_count} existing skills. Total skills: {result['total_skills']}"
                );
                
                # Clear resume text
                setResumeText("");
            }
        } except err {
            console.error("Error parsing resume:", err);
            setMessage("Failed to parse resume. Please try again.");
        }
        
        setParseLoading(False);
        setTimeout(lambda   -> None{ setMessage("");} , 5000);
    }

    if loading {
        return <div
            style={{"padding": "2rem", "textAlign": "center"}}
        >
            Loading profile...
        </div>;
    }

    return <div
        style={{"maxWidth": "800px", "margin": "0 auto", "padding": "2rem 1rem"}}
    >
        <h2
            style={{
                "fontSize": "1.5rem",
                "fontWeight": "bold",
                "marginBottom": "2rem",
                "color": "#1f2937"
            }}
        >
            Edit Profile
        </h2>
        <div
            style={{
                "background": "white",
                "padding": "2rem",
                "borderRadius": "12px",
                "boxShadow": "0 4px 6px -1px rgba(0, 0, 0, 0.1)"
            }}
        >
            <div
                style={{"marginBottom": "2rem"}}
            >
                <label
                    style={{
                        "display": "block",
                        "marginBottom": "0.5rem",
                        "fontWeight": "600",
                        "color": "#374151"
                    }}
                >
                    Full Name
                </label>
                <input
                    type="text"
                    value={profile["name"]}
                    onChange={lambda  e: any  -> None{ handleUpdateField(
                        "name", e.target.value
                    );} }
                    placeholder="e.g. Jane Doe"
                    style={{
                        "width": "100%",
                        "padding": "0.75rem",
                        "border": "1px solid #d1d5db",
                        "borderRadius": "6px",
                        "fontSize": "1rem"
                    }}
                />
            </div>
            <div
                style={{"marginBottom": "2rem"}}
            >
                <label
                    style={{
                        "display": "block",
                        "marginBottom": "0.5rem",
                        "fontWeight": "600",
                        "color": "#374151"
                    }}
                >
                    Target Role
                </label>
                <input
                    list="profile-roles-list"
                    type="text"
                    value={profile["target_role"]}
                    onChange={lambda  e: any  -> None{ handleUpdateField(
                        "target_role", e.target.value
                    );} }
                    placeholder="e.g. Senior Software Engineer"
                    style={{
                        "width": "100%",
                        "padding": "0.75rem",
                        "border": "1px solid #d1d5db",
                        "borderRadius": "6px",
                        "fontSize": "1rem"
                    }}
                />
                <datalist id="profile-roles-list">
                    {availableRoles.map(lambda r: any, i: int -> any {
                        return <option key={i} value={r.title}>{r.description}</option>;
                    })}
                </datalist>
                <p
                    style={{
                        "fontSize": "0.875rem",
                        "color": "#6b7280",
                        "marginTop": "0.5rem"
                    }}
                >
                    This role is used to generate your career roadmap and job suggestions.
                </p>
            </div>
            <div
                style={{"marginBottom": "2rem"}}
            >
                <label
                    style={{
                        "display": "block",
                        "marginBottom": "0.5rem",
                        "fontWeight": "600",
                        "color": "#374151"
                    }}
                >
                    Interests
                </label>
                <div
                    style={{
                        "display": "flex",
                        "flexWrap": "wrap",
                        "gap": "0.5rem",
                        "marginBottom": "1rem"
                    }}
                >
                    {profile["interests"].map(
                        lambda  i: str  -> any{ return <span
                            style={{
                                "background": "#f3f4f6",
                                "padding": "0.5rem 1rem",
                                "borderRadius": "9999px",
                                "fontSize": "0.875rem",
                                "display": "flex",
                                "alignItems": "center",
                                "gap": "0.5rem",
                                "color": "#374151"
                            }}
                        >
                            {i}
                            <button
                                onClick={lambda  e: any  -> None{ handleDeleteList(
                                    "interests", i
                                );} }
                                style={{
                                    "background": "none",
                                    "border": "none",
                                    "color": "#ef4444",
                                    "cursor": "pointer",
                                    "fontWeight": "bold",
                                    "padding": "0",
                                    "fontSize": "1.1rem",
                                    "lineHeight": "1"
                                }}
                            >
                                ×
                            </button>
                        </span>; }
                    )}
                </div>
                <div
                    style={{"display": "flex", "gap": "0.5rem"}}
                >
                    <input
                        type="text"
                        value={newInterest}
                        onChange={lambda  e: any  -> None{ setNewInterest(
                            e.target.value
                        );} }
                        placeholder="Add interest..."
                        style={{
                            "flex": 1,
                            "padding": "0.75rem",
                            "border": "1px solid #d1d5db",
                            "borderRadius": "6px"
                        }}
                    />
                    <button
                        onClick={lambda  e: any  -> None{ handleAddList(
                            "interests", newInterest, setNewInterest
                        );} }
                        style={{
                            "padding": "0.75rem 1.5rem",
                            "background": "#4b5563",
                            "color": "white",
                            "border": "none",
                            "borderRadius": "6px",
                            "cursor": "pointer",
                            "fontWeight": "600"
                        }}
                    >
                        Add
                    </button>
                </div>
            </div>
            <div
                style={{"marginBottom": "2rem"}}
            >
                <label
                    style={{
                        "display": "block",
                        "marginBottom": "0.5rem",
                        "fontWeight": "600",
                        "color": "#374151"
                    }}
                >
                    Career Goals
                </label>
                <div
                    style={{
                        "display": "flex",
                        "flexWrap": "wrap",
                        "gap": "0.5rem",
                        "marginBottom": "1rem"
                    }}
                >
                    {profile["goals"].map(
                        lambda  g: str  -> any{ return <span
                            style={{
                                "background": "#f3f4f6",
                                "padding": "0.5rem 1rem",
                                "borderRadius": "9999px",
                                "fontSize": "0.875rem",
                                "display": "flex",
                                "alignItems": "center",
                                "gap": "0.5rem",
                                "color": "#374151"
                            }}
                        >
                            {g}
                            <button
                                onClick={lambda  e: any  -> None{ handleDeleteList(
                                    "goals", g
                                );} }
                                style={{
                                    "background": "none",
                                    "border": "none",
                                    "color": "#ef4444",
                                    "cursor": "pointer",
                                    "fontWeight": "bold",
                                    "padding": "0",
                                    "fontSize": "1.1rem",
                                    "lineHeight": "1"
                                }}
                            >
                                ×
                            </button>
                        </span>; }
                    )}
                </div>
                <div
                    style={{"display": "flex", "gap": "0.5rem"}}
                >
                    <input
                        type="text"
                        value={newGoal}
                        onChange={lambda  e: any  -> None{ setNewGoal(e.target.value);} }
                        placeholder="Add goal..."
                        style={{
                            "flex": 1,
                            "padding": "0.75rem",
                            "border": "1px solid #d1d5db",
                            "borderRadius": "6px"
                        }}
                    />
                    <button
                        onClick={lambda  e: any  -> None{ handleAddList(
                            "goals", newGoal, setNewGoal
                        );} }
                        style={{
                            "padding": "0.75rem 1.5rem",
                            "background": "#4b5563",
                            "color": "white",
                            "border": "none",
                            "borderRadius": "6px",
                            "cursor": "pointer",
                            "fontWeight": "600"
                        }}
                    >
                        Add
                    </button>
                </div>
            </div>
            <div
                style={{"marginBottom": "2rem"}}
            >
                <button
                    onClick={handleSaveProfile}
                    style={{
                        "width": "100%",
                        "padding": "1rem",
                        "background": "#2563eb",
                        "color": "white",
                        "border": "none",
                        "borderRadius": "6px",
                        "cursor": "pointer",
                        "fontWeight": "bold",
                        "fontSize": "1rem",
                        "transition": "background 0.2s"
                    }}
                >
                    Save Profile Changes
                </button>
                {message
                and <div
                    style={{
                        "marginTop": "1rem",
                        "color": "#059669",
                        "textAlign": "center",
                        "fontWeight": "500"
                    }}
                >
                    {message}
                </div>}
            </div>
            <div
                style={{"borderTop": "1px solid #e5e7eb", "paddingTop": "2rem"}}
            >
                <label
                    style={{
                        "display": "block",
                        "marginBottom": "0.5rem",
                        "fontWeight": "600",
                        "color": "#374151"
                    }}
                >
                    Skills (Graph Nodes)
                </label>
                <p
                    style={{
                        "fontSize": "0.875rem",
                        "color": "#6b7280",
                        "marginBottom": "1rem"
                    }}
                >
                    These are stored directly in the knowledge graph and used for AI analysis.
                </p>
                
                <div
                    style={{
                        "marginBottom": "1.5rem",
                        "padding": "1rem",
                        "background": "#fef3c7",
                        "borderRadius": "8px",
                        "border": "1px solid #fbbf24"
                    }}
                >
                    <h4
                        style={{
                            "fontSize": "0.875rem",
                            "fontWeight": "600",
                            "marginBottom": "0.5rem",
                            "color": "#92400e"
                        }}
                    >
                        ⚡ Quick Import from Resume
                    </h4>
                    <textarea
                        value={resumeText}
                        onChange={lambda  e: any  -> None{ setResumeText(e.target.value);} }
                        placeholder="Paste your resume text here (we'll extract skills automatically)..."
                        rows={4}
                        style={{
                            "width": "100%",
                            "padding": "0.75rem",
                            "border": "1px solid #fbbf24",
                            "borderRadius": "6px",
                            "fontSize": "0.875rem",
                            "marginBottom": "0.5rem",
                            "fontFamily": "monospace"
                        }}
                    />
                    <button
                        onClick={handleResumeUpload}
                        disabled={parseLoading or not resumeText}
                        style={{
                            "padding": "0.5rem 1rem",
                            "background": "#f59e0b",
                            "color": "white",
                            "border": "none",
                            "borderRadius": "6px",
                            "fontSize": "0.875rem",
                            "fontWeight": "600",
                            "cursor": "pointer"
                        }}
                    >
                        Parse Resume & Add Skills
                    </button>
                </div>
                
                <div
                    style={{
                        "display": "flex",
                        "flexWrap": "wrap",
                        "gap": "0.5rem",
                        "marginBottom": "1rem"
                    }}
                >
                    {profile["skills"].map(
                        lambda  s: str  -> any{ return <span
                            style={{
                                "background": "#dbeafe",
                                "color": "#1e40af",
                                "padding": "0.5rem 1rem",
                                "borderRadius": "9999px",
                                "fontSize": "0.875rem",
                                "display": "flex",
                                "alignItems": "center",
                                "gap": "0.5rem",
                                "fontWeight": "500"
                            }}
                        >
                            {s}
                            <button
                                onClick={lambda  e: any  -> None{ handleDeleteSkill(s);} }
                                style={{
                                    "background": "none",
                                    "border": "none",
                                    "color": "#ef4444",
                                    "cursor": "pointer",
                                    "fontWeight": "bold",
                                    "padding": "0",
                                    "fontSize": "1.1rem",
                                    "lineHeight": "1"
                                }}
                            >
                                ×
                            </button>
                        </span>; }
                    )}
                </div>
                <div
                    style={{"display": "flex", "gap": "0.5rem"}}
                >
                    <input
                        type="text"
                        value={newSkill}
                        onChange={lambda  e: any  -> None{ setNewSkill(e.target.value);} }
                        placeholder="Add skill (e.g. Python)"
                        style={{
                            "flex": 1,
                            "padding": "0.75rem",
                            "border": "1px solid #d1d5db",
                            "borderRadius": "6px"
                        }}
                    />
                    <button
                        onClick={handleAddSkill}
                        style={{
                            "padding": "0.75rem 1.5rem",
                            "background": "#10b981",
                            "color": "white",
                            "border": "none",
                            "borderRadius": "6px",
                            "cursor": "pointer",
                            "fontWeight": "600"
                        }}
                    >
                        Add Skill
                    </button>
                </div>
            </div>
        </div>
    </div>;
}
