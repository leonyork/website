import React from "react"

import Jumbotron from "react-bootstrap/Jumbotron"
import Container from "react-bootstrap/Container"

import Layout from "../layout"

const LayoutAuthDemo = (props) => {
    return (
        <Layout>
            <Jumbotron style={{ paddingTop: "1.5em", paddingBottom: "4em" }}>
                <Container>
                    <h1 style={{ fontFamily: "HanleyPro-Slim" }}>{props.title}</h1>
                    <hr className="my-4" />
                    {props.lead && <p className="lead">{props.lead}</p>}
                    {props.leadtext}
                    <div className="mt-3" id="auth-options">
                        {props.authOptions}
                    </div>
                </Container>
            </Jumbotron>
            {props.children}
        </Layout>
    )
}

export default LayoutAuthDemo