cl import from react { useState, useEffect }
cl import from "@jac-client/utils" {
    Link,
    useNavigate,
    useLocation,
    jacLogout,
    jacIsLoggedIn
}

cl def Navbar()  -> any {
    let location = useLocation();
    let isLoggedIn = jacIsLoggedIn();
    let navigate = useNavigate();

    def handleLogout(e: any) -> None {
        e.preventDefault();
        jacLogout();
        navigate("/login");
    }

    let navLinks = None;
    if isLoggedIn {
        navLinks = <div
            style={{"display": "flex", "gap": "1rem", "alignItems": "center"}}
        >
            <Link
                to="/"
                style={{"color": "white", "textDecoration": "none"}}
            >
                Dashboard
            </Link>
            <Link
                to="/career"
                style={{"color": "white", "textDecoration": "none"}}
            >
                Career Path
            </Link>
            <Link
                to="/jobs"
                style={{"color": "white", "textDecoration": "none"}}
            >
                Jobs
            </Link>
            <Link
                to="/profile"
                style={{"color": "white", "textDecoration": "none"}}
            >
                Profile
            </Link>
            <button
                onClick={handleLogout}
                style={{
                    "background": "transparent",
                    "border": "1px solid white",
                    "color": "white",
                    "padding": "0.25rem 0.75rem",
                    "borderRadius": "4px",
                    "cursor": "pointer"
                }}
            >
                Logout
            </button>
        </div>;
    } else {
        navLinks = <div
            style={{"display": "flex", "gap": "1rem", "alignItems": "center"}}
        >
            <Link
                to="/login"
                style={{"color": "white", "textDecoration": "none"}}
            >
                Login
            </Link>
            <Link
                to="/signup"
                style={{"color": "white", "textDecoration": "none"}}
            >
                Sign Up
            </Link>
        </div>;
    }

    return <nav
        style={{
            "background": "#2563eb",
            "padding": "1rem",
            "color": "white",
            "marginBottom": "2rem"
        }}
    >
        <div
            style={{
                "maxWidth": "1200px",
                "margin": "0 auto",
                "display": "flex",
                "justifyContent": "space-between",
                "alignItems": "center"
            }}
        >
            <h1
                style={{"margin": 0, "fontSize": "1.5rem"}}
            >
                Career Navigator
            </h1>
            {navLinks}
        </div>
    </nav>;
}
