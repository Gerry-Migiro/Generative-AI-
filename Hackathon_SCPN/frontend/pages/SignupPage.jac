cl import from react { useState }
cl import from "@jac-client/utils" { Link, useNavigate, jacSignup }

cl def SignupPage()  -> any {
    let [username, setUsername] = useState("");
    let [password, setPassword] = useState("");
    let [error, setError] = useState("");
    let navigate = useNavigate();

    async def handleSignup(e: any) -> None {
        e.preventDefault();
        setError("");
        if not username or not password {
            setError("Please fill in all fields");
            return;
        }

        result = await jacSignup(username, password);
        if result["success"] {
            navigate("/");
        } else {
            setError(result["error"] if result["error"] else "Signup failed");
        }
    }

    def handleUsernameChange(e: any) -> None {
        setUsername(e.target.value);
    }

    def handlePasswordChange(e: any) -> None {
        setPassword(e.target.value);
    }

    let errorDisplay = None;
    if error {
        errorDisplay = <div
            style={{"color": "#dc2626", "fontSize": "14px", "marginBottom": "10px"}}
        >
            {error}
        </div>;
    }

    return <div
        className="container"
        style={{
            "display": "flex",
            "justifyContent": "center",
            "alignItems": "center",
            "height": "100vh"
        }}
    >
        <form
            onSubmit={handleSignup}
            className="card"
            style={{"width": "100%", "maxWidth": "400px", "padding": "2.5rem"}}
        >
            <h2
                style={{
                    "textAlign": "center",
                    "marginBottom": "0.5rem",
                    "fontSize": "1.75rem"
                }}
            >
                Create Account
            </h2>
            <p
                style={{
                    "textAlign": "center",
                    "color": "var(--muted-foreground)",
                    "marginBottom": "2rem"
                }}
            >
                Join to accelerate your career
            </p>
            <div className="form-group">
                <label className="form-label">
                    Username
                </label>
                <input
                    type="text"
                    placeholder="Choose a username"
                    value={username}
                    onChange={handleUsernameChange}
                    className="form-input"
                    style={{"marginBottom": "1rem"}}
                />
            </div>
            <div className="form-group">
                <label className="form-label">
                    Password
                </label>
                <input
                    type="password"
                    placeholder="Choose a strong password"
                    value={password}
                    onChange={handlePasswordChange}
                    className="form-input"
                    style={{"marginBottom": "1.5rem"}}
                />
            </div>
            {errorDisplay}
            <button
                type="submit"
                className="btn btn-primary"
                style={{"width": "100%"}}
            >
                Get Started
            </button>
            <div
                style={{
                    "textAlign": "center",
                    "marginTop": "1.5rem",
                    "fontSize": "0.9rem",
                    "color": "var(--muted-foreground)"
                }}
            >
                Already have an account?
                <Link to="/login">
                    Sign In
                </Link>
            </div>
        </form>
    </div>;
}
