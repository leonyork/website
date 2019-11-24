import React from "react"

import Jumbotron from "react-bootstrap/Jumbotron"
import Container from "react-bootstrap/Container"
import Button from "react-bootstrap/Button"

import Layout from "../../components/layout"
import addCms from "../../cms/auth-demo/index-cms"

import Message from "../../components/auth-demo/message"

export default function IndexPage(props) {
    let jumbo = addCms(props)

    const login = async () => {
        window.location.href = `https://${
            process.env.REACT_APP_COGNITO_HOST
            }/oauth2/authorize?response_type=token&client_id=${
            process.env.REACT_APP_CLIENT_ID
            }&redirect_uri=${encodeURI(process.env.REACT_APP_REDIRECT_URL)}`;
    }

    const logout = async () => {
        window.location.href = `https://${
            process.env.REACT_APP_COGNITO_HOST
            }/logout?client_id=${
            process.env.REACT_APP_CLIENT_ID
            }&logout_uri=${encodeURI(process.env.REACT_APP_REDIRECT_URL)}`;
    }

    const accessToken = () => {
        if (typeof window !== 'undefined') {
            return new URLSearchParams(window.location.hash.split("#")[1]).get("access_token")
        } else {
            return undefined
        }
    }

    return (
        <Layout>
            <Jumbotron style={{ paddingTop: "1.5em", paddingBottom: "4em" }}>
                <Container>
                    <h1 style={{ fontFamily: "HanleyPro-Slim" }}>{jumbo.title}</h1>
                    <hr className="my-4" />
                    {!accessToken() && jumbo.lead && <p className="lead">{jumbo.lead}</p>}
                    {!accessToken() && jumbo.leadtext && jumbo.leadtext.split(/[\r\n]/).map((line, index) => (
                        <p key={index}>{line}</p>
                    ))}
                    <div className="mt-3">
                        {accessToken() ?
                            <Button variant="primary" onClick={logout}>Logout</Button> :
                            <Button variant="primary" onClick={login}>Login</Button>
                        }
                    </div>
                </Container>
            </Jumbotron>
            {accessToken() && (
                <Container>
                    <Message accessToken={accessToken()} />
                </Container>
            )}
        </Layout>
    )
}

IndexPage.getInitialProps = function (ctx) {
    let jumbo = require(`../../content/auth-demo/jumbo.json`)

    return {
        fileRelativePath: `/content/auth-demo/jumbo.json`,
        title: jumbo.title,
        lead: jumbo.lead,
        leadtext: jumbo.leadtext
    }
}
