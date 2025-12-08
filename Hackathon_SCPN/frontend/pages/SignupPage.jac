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
        style={{
            "display": "flex",
            "justifyContent": "center",
            "alignItems": "center",
            "height": "100vh",
            "background": "#f3f4f6"
        }}
    >
        <form
            onSubmit={handleSignup}
            style={{
                "background": "white",
                "padding": "2rem",
                "borderRadius": "8px",
                "boxShadow": "0 4px 6px rgba(0,0,0,0.1)",
                "width": "300px"
            }}
        >
            <h2
                style={{"textAlign": "center", "marginBottom": "1.5rem"}}
            >
                Sign Up
            </h2>
            <input
                type="text"
                placeholder="Username"
                value={username}
                onChange={handleUsernameChange}
                style={{
                    "width": "100%",
                    "padding": "0.5rem",
                    "marginBottom": "1rem",
                    "border": "1px solid #d1d5db",
                    "borderRadius": "4px"
                }}
            />
            <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={handlePasswordChange}
                style={{
                    "width": "100%",
                    "padding": "0.5rem",
                    "marginBottom": "1.5rem",
                    "border": "1px solid #d1d5db",
                    "borderRadius": "4px"
                }}
            />
            {errorDisplay}
            <button
                type="submit"
                style={{
                    "width": "100%",
                    "padding": "0.75rem",
                    "background": "#2563eb",
                    "color": "white",
                    "border": "none",
                    "borderRadius": "4px",
                    "cursor": "pointer"
                }}
            >
                Sign Up
            </button>
            <div
                style={{"textAlign": "center", "marginTop": "1rem"}}
            >
                <Link to="/login">
                    Back to Login
                </Link>
            </div>
        </form>
    </div>;
}
