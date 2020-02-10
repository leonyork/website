import React from "react"

const AuthOptions = (props) => { 
    if (props.loggedIn) {
        const logoutUrl = `${
            process.env.REACT_APP_COGNITO_HOST
            }/logout?client_id=${
            process.env.REACT_APP_CLIENT_ID
            }&logout_uri=${encodeURI(process.env.REACT_APP_URL)}/auth-demo`
        return (
            <a className={"btn btn-primary"} href={logoutUrl} key={"logout"}>Logout</a> 
        )
    }
    else {
        const loginUrl = `${
            process.env.REACT_APP_COGNITO_HOST
            }/oauth2/authorize?response_type=token&scope=openid&client_id=${
            process.env.REACT_APP_CLIENT_ID
            }&redirect_uri=${encodeURI(process.env.REACT_APP_URL)}/auth-demo`
        return (
            <a className={"btn btn-primary"} href={loginUrl} key={"login"}>Login</a>
        )
    }
}

export default AuthOptions