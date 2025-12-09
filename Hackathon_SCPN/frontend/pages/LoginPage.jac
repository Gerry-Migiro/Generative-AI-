cl import from react { useState }
cl import from "@jac-client/utils" { Link, useNavigate, jacLogin }

cl def LoginPage()  -> any {
    let [username, setUsername] = useState("");
    let [password, setPassword] = useState("");
    let [error, setError] = useState("");
    let navigate = useNavigate();

    async def handleLogin(e: any) -> None {
        e.preventDefault();
        setError("");
        if not username or not password {
            setError("Please fill in all fields");
            return;
        }

        success = await jacLogin(username, password);
        if success {
            navigate("/");
        } else {
            setError("Invalid credentials");
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
            onSubmit={handleLogin}
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
                Welcome Back
            </h2>
            <p
                style={{
                    "textAlign": "center",
                    "color": "var(--muted-foreground)",
                    "marginBottom": "2rem"
                }}
            >
                Sign in to continue your journey
            </p>
            <div className="form-group">
                <label className="form-label">
                    Username
                </label>
                <input
                    type="text"
                    placeholder="Enter your username"
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
                    placeholder="Enter your password"
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
                Sign In
            </button>
            <div
                style={{
                    "textAlign": "center",
                    "marginTop": "1.5rem",
                    "fontSize": "0.9rem",
                    "color": "var(--muted-foreground)"
                }}
            >
                Don't have an account?
                <Link to="/signup">
                    Create one
                </Link>
            </div>
        </form>
    </div>;
}
