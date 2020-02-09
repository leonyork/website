import React, { useState, useEffect } from "react"

import Container from "react-bootstrap/Container"

import Layout from "../../components/auth-demo/layout"
import addCms from "../../cms/auth-demo/index-cms"

import Message from "../../components/auth-demo/message"
import AuthOptions from "../../components/auth-demo/auth-options"

export default function IndexPage(props) {
    let jumbo = addCms(props)

    const [accessToken, setAccessToken] = useState(undefined);

    useEffect(() => {
        setAccessToken(new URLSearchParams(window.location.hash.split("#")[1]).get("access_token"))    
    })

    return (
        <Layout title={jumbo.title} lead={jumbo.lead} 
            leadtext={jumbo.leadtext ? jumbo.leadtext.split(/[\r\n]/).map((line, index) => (
                <p key={index}>{line}</p>
            )) : undefined}
            authOptions={<AuthOptions loggedIn={accessToken} />}>
                {accessToken && (
                    <Container>
                        <Message accessToken={accessToken} />
                    </Container>
                )}
        </Layout>
    )
}

IndexPage.getInitialProps = function (ctx) {
    const jumbo = require(`../../content/auth-demo/jumbo.json`)

    return {
        fileRelativePath: `/content/auth-demo/jumbo.json`,
        title: jumbo.title,
        lead: jumbo.lead,
        leadtext: jumbo.leadtext
    }
}
