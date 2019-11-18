import React from "react"

import Jumbotron from "react-bootstrap/Jumbotron"
import Container from "react-bootstrap/Container"
import Button from "react-bootstrap/Button"

import Layout from "../../components/layout"

import addCms from "../../cms/auth-demo/index-cms"

export default function IndexPage(props) {
    let jumbo = addCms(props)

    return (
        <Layout>
            <Jumbotron style={{ paddingTop: "1.5em", paddingBottom: "4em" }}>
                <Container>
                    <h1 style={{ fontFamily: "HanleyPro-Slim" }}>{jumbo.title}</h1>
                    <hr className="my-4" />
                    {jumbo.lead && <p className="lead">{jumbo.lead}</p>}
                    {jumbo.leadtext && jumbo.leadtext.split(/[\r\n]/).map((line, index) => (
                        <p key={index}>{line}</p>
                    ))}
                    <div className="mt-3">
                        <Button variant="primary" onClick={login}>
                            Login
                        </Button>
                    </div>
                </Container>
            </Jumbotron>
        </Layout>
    )
}

const login = () => {
    window.location.href = `https://${
        process.env.REACT_APP_COGNITO_HOST
      }/oauth2/authorize?response_type=token&client_id=${
        process.env.REACT_APP_CLIENT_ID
      }&redirect_uri=${encodeURI(process.env.REACT_APP_REDIRECT_URL)}`;
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
