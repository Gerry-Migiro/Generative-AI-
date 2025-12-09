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
        navLinks = <div className="nav-items">
            <Link
                to="/"
                className="nav-link"
            >
                Dashboard
            </Link>
            <Link
                to="/career"
                className="nav-link"
            >
                Career Path
            </Link>
            <Link
                to="/jobs"
                className="nav-link"
            >
                Jobs
            </Link>
            <Link
                to="/profile"
                className="nav-link"
            >
                Profile
            </Link>
            <Link
                to="/courses"
                className="nav-link"
            >
                Courses
            </Link>
            <button
                onClick={handleLogout}
                className="btn btn-outline-light btn-sm"
            >
                Logout
            </button>
        </div>;
    } else {
        navLinks = <div className="nav-items">
            <Link
                to="/login"
                className="nav-link"
            >
                Login
            </Link>
            <Link
                to="/signup"
                className="nav-link"
            >
                Sign Up
            </Link>
        </div>;
    }

    return <nav className="navbar">
        <div className="container navbar-container">
            <h1 className="navbar-brand">
                Career Navigator
            </h1>
            {navLinks}
        </div>
    </nav>;
}
