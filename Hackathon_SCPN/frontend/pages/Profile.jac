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
                    f"Resume parsed! Added {added_count} new skills, skipped {skipped_count} existing skills. Total skills: {result[
                        'total_skills'
                    ]}"
                );
                # Clear resume text
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
        className="container"
        style={{"maxWidth": "1000px", "padding": "2rem 1rem"}}
    >
        <div
            className="flex-between"
            style={{"marginBottom": "2rem"}}
        >
            <h1
                style={{
                    "fontSize": "2rem",
                    "fontWeight": "700",
                    "color": "var(--foreground)"
                }}
            >
                Professional Profile
            </h1>
        </div>
        <div className="card">
            <div className="form-group">
                <label className="form-label">
                    Full Name
                </label>
                <input
                    type="text"
                    value={profile["name"]}
                    onChange={lambda  e: any  -> None{ handleUpdateField(
                        "name", e.target.value
                    );} }
                    placeholder="e.g. Jane Doe"
                    className="form-input"
                />
            </div>
            <div className="form-group">
                <label className="form-label">
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
                    className="form-input"
                />
                <datalist id="profile-roles-list">
                    {availableRoles.map(
                        lambda  r: any , i: int  -> any{ return <option
                            key={i}
                            value={r.title}
                        >
                            {r.description}
                        </option>; }
                    )}
                </datalist>
                <p className="text-sub">
                    This role is used to generate your career roadmap and job suggestions.
                </p>
            </div>
            <div className="form-group">
                <label className="form-label">
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
                            className="badge badge-gray"
                            style={{
                                "display": "flex",
                                "alignItems": "center",
                                "gap": "0.5rem"
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
                                    "color": "var(--brand)",
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
                        className="form-input"
                        style={{"flex": 1}}
                    />
                    <button
                        onClick={lambda  e: any  -> None{ handleAddList(
                            "interests", newInterest, setNewInterest
                        );} }
                        className="btn btn-secondary"
                    >
                        Add
                    </button>
                </div>
            </div>
            <div className="form-group">
                <label className="form-label">
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
                            className="badge badge-gray"
                            style={{
                                "display": "flex",
                                "alignItems": "center",
                                "gap": "0.5rem"
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
                                    "color": "var(--brand)",
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
                        className="form-input"
                        style={{"flex": 1}}
                    />
                    <button
                        onClick={lambda  e: any  -> None{ handleAddList(
                            "goals", newGoal, setNewGoal
                        );} }
                        className="btn btn-secondary"
                    >
                        Add
                    </button>
                </div>
            </div>
            <div className="form-group">
                <button
                    onClick={handleSaveProfile}
                    className="btn btn-primary"
                    style={{"width": "100%", "padding": "1rem", "fontSize": "1rem"}}
                >
                    Save Profile Changes
                </button>
                {message
                and <div
                    style={{
                        "marginTop": "1rem",
                        "color": "var(--success)",
                        "textAlign": "center",
                        "fontWeight": "500"
                    }}
                >
                    {message}
                </div>}
            </div>
            <div
                style={{"borderTop": "1px solid var(--border)", "paddingTop": "2rem"}}
            >
                <label className="form-label">
                    Skills (Graph Nodes)
                </label>
                <p
                    className="text-sub"
                    style={{"marginBottom": "1rem"}}
                >
                    These are stored directly in the knowledge graph and used for AI analysis.
                </p>
                <div
                    style={{
                        "marginBottom": "1.5rem",
                        "padding": "1rem",
                        "background": "var(--secondary)",
                        "borderRadius": "var(--radius-md)",
                        "border": "1px solid var(--border)"
                    }}
                >
                    <h4
                        style={{
                            "fontSize": "0.875rem",
                            "fontWeight": "600",
                            "marginBottom": "0.5rem",
                            "color": "var(--brand)"
                        }}
                    >
                        ⚡ Quick Import from Resume
                    </h4>
                    <textarea
                        value={resumeText}
                        onChange={lambda  e: any  -> None{ setResumeText(
                            e.target.value
                        );} }
                        placeholder="Paste your resume text here (we'll extract skills automatically)..."
                        rows={4}
                        className="form-input"
                        style={{"marginBottom": "0.5rem", "fontFamily": "monospace"}}
                    />
                    <button
                        onClick={handleResumeUpload}
                        disabled={parseLoading or not resumeText}
                        className="btn btn-primary"
                        style={{
                            "fontSize": "0.875rem",
                            "width": "100%",
                            "justifyContent": "center",
                            "marginTop": "0.5rem"
                        }}
                    >
                        {parseLoading and "Parsing..."}{not parseLoading
                        and "✨ Parse Resume & Add Skills"}
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
                            className="badge badge-blue"
                            style={{
                                "display": "flex",
                                "alignItems": "center",
                                "gap": "0.5rem"
                            }}
                        >
                            {s}
                            <button
                                onClick={lambda  e: any  -> None{ handleDeleteSkill(s);} }
                                style={{
                                    "background": "none",
                                    "border": "none",
                                    "color": "var(--error)",
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
                        className="form-input"
                        style={{"flex": 1}}
                    />
                    <button
                        onClick={handleAddSkill}
                        className="btn btn-primary"
                        style={{"background": "oklch(0.65 0.2 145)"}}
                    >
                        Add Skill
                    </button>
                </div>
            </div>
        </div>
    </div>;
}
