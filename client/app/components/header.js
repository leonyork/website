import React from "react"
import Navbar from "react-bootstrap/Navbar"
import Nav from "react-bootstrap/Nav"
import styles from "./header.module.css"

const Header = () => (
  <Navbar bg="primary" variant="dark" expand="sm" sticky="top" collapseOnSelect={true}>
    <Navbar.Brand className={styles.logo} href="/">
      Leon York
    </Navbar.Brand>
    <Navbar.Toggle aria-controls="basic-navbar-nav" className={styles.toggle}>
      <span className="navbar-toggler-icon"></span>
    </Navbar.Toggle>
    <Navbar.Collapse id="basic-navbar-nav" className={styles.navbar}>
      <Nav className="mr-auto" className={styles.nav}>
        <Nav.Link href="/#projects" active={false/*Don't stop the hover working once the link is clicked*/}>Projects</Nav.Link>
        <Nav.Link href="/#links" active={false/*Don't stop the hover working once the link is clicked*/}>Links</Nav.Link>
      </Nav>
      <Nav className="ml-auto" >
        <Nav.Link href="https://www.npmjs.com/~leonyork">
          <svg className={styles.navlinksvg} version="1.1" xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" viewBox="0 0 18 7">
            <title>npm</title>
            <path fill="currentColor" d="M0,0h18v6H9v1H5V6H0V0z M1,5h2V2h1v3h1V1H1V5z M6,1v5h2V5h2V1H6z M8,2h1v2H8V2z M11,1v4h2V2h1v3h1V2h1v3h1V1H11z" />
          </svg>
        </Nav.Link>
        <Nav.Link href="https://hub.docker.com/u/leonyork">
          <svg className={styles.navlinksvg} xmlns="http://www.w3.org/2000/svg" viewBox="64 64 400 400">
            <title>DockerHub</title>
            <path fill="currentColor" d="M296 245h42v-38h-42zm-50 0h42v-38h-42zm-49 0h42v-38h-42zm-49 0h41v-38h-41zm-50 0h42v-38H98zm50-46h41v-38h-41zm49 0h42v-38h-42zm49 0h42v-38h-42zm0-46h42v-38h-42zm226 75s-18-17-55-11c-4-29-35-46-35-46s-29 35-8 74c-6 3-16 7-31 7H68c-5 19-5 145 133 145 99 0 173-46 208-130 52 4 63-39 63-39z" />
          </svg>
        </Nav.Link>
        <Nav.Link href="https://github.com/leonyork">
          <svg className={styles.navlinksvg} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 499.36">
            <title>GitHub</title>
            <path fill="currentColor" fillRule="evenodd" d="M256 0C114.64 0 0 114.61 0 256c0 113.09 73.34 209 175.08 242.9 12.8 2.35 17.47-5.56 17.47-12.34 0-6.08-.22-22.18-.35-43.54-71.2 15.49-86.2-34.34-86.2-34.34-11.64-29.57-28.42-37.45-28.42-37.45-23.27-15.84 1.73-15.55 1.73-15.55 25.69 1.81 39.21 26.38 39.21 26.38 22.84 39.12 59.92 27.82 74.5 21.27 2.33-16.54 8.94-27.82 16.25-34.22-56.84-6.43-116.6-28.43-116.6-126.49 0-27.95 10-50.8 26.35-68.69-2.63-6.48-11.42-32.5 2.51-67.75 0 0 21.49-6.88 70.4 26.24a242.65 242.65 0 0 1 128.18 0c48.87-33.13 70.33-26.24 70.33-26.24 14 35.25 5.18 61.27 2.55 67.75 16.41 17.9 26.31 40.75 26.31 68.69 0 98.35-59.85 120-116.88 126.32 9.19 7.9 17.38 23.53 17.38 47.41 0 34.22-.31 61.83-.31 70.23 0 6.85 4.61 14.81 17.6 12.31C438.72 464.97 512 369.08 512 256.02 512 114.62 397.37 0 256 0z"></path>
          </svg>
        </Nav.Link>
      </Nav>
    </Navbar.Collapse>
  </Navbar>
)

export default Header
