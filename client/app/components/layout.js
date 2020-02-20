/**
 * Layout component that queries for data
 * with Gatsby's useStaticQuery component
 *
 * See: https://www.gatsbyjs.org/docs/use-static-query/
 */

import React from "react"
import Head from "next/head"

import Header from "./header"
import "./fonts.css"
import "./bootstrap.css"

const Layout = (props) => {

  return (
    <>
      <Head>
        <title>Leon York</title>
        <meta name="description" content="Leon York's Website" />
        <meta name="keywords" content="HTML, CSS, Design, Development, Digital, Java, Healthcare, SQL, SQL Server" />

        <link rel="apple-touch-icon" sizes="57x57" href="/favicon/apple-touch-icon-57x57.png" />
        <link rel="apple-touch-icon" sizes="114x114" href="/favicon/apple-touch-icon-114x114.png" />
        <link rel="apple-touch-icon" sizes="72x72" href="/favicon/apple-touch-icon-72x72.png" />
        <link rel="apple-touch-icon" sizes="144x144" href="/favicon/apple-touch-icon-144x144.png" />
        <link rel="apple-touch-icon" sizes="60x60" href="/favicon/apple-touch-icon-60x60.png" />
        <link rel="apple-touch-icon" sizes="120x120" href="/favicon/apple-touch-icon-120x120.png" />
        <link rel="apple-touch-icon" sizes="76x76" href="/favicon/apple-touch-icon-76x76.png" />
        <link rel="apple-touch-icon" sizes="152x152" href="/favicon/apple-touch-icon-152x152.png" />
        <link rel="icon" type="image/png" href="favicon-196x196.png" sizes="196x196" />
        <link rel="icon" type="image/png" href="favicon-96x96.png" sizes="96x96" />
        <link rel="icon" type="image/png" href="favicon-32x32.png" sizes="32x32" />
        <link rel="icon" type="image/png" href="favicon-16x16.png" sizes="16x16" />
        <link rel="icon" type="image/png" href="favicon-128.png" sizes="128x128" />
        <link rel="manifest" href="/manifest.json"></link>
        <meta name="application-name" content="Leon York" />
        <meta name="theme-color" content="#2C3E50" />
        <meta name="msapplication-TileColor" content="#2C3E50" />
        <meta name="msapplication-TileImage" content="/favicon/mstile-144x144.png" />
        <meta name="msapplication-square70x70logo" content="/favicon/mstile-70x70.png" />
        <meta name="msapplication-square150x150logo" content="/favicon/mstile-150x150.png" />
        <meta name="msapplication-wide310x150logo" content="/favicon/mstile-310x150.png" />
        <meta name="msapplication-square310x310logo" content="/favicon/mstile-310x310.png" />

        <link rel="preconnect" href="https://fonts.gstatic.com"></link>
      </Head>
      <Header />
      <main>{props.children}</main>
    </>
  )
}

export default Layout
