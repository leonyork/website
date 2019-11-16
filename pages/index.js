import * as React from "react"
import Jumbotron from "react-bootstrap/Jumbotron"
import Container from "react-bootstrap/Container"
import Card from "react-bootstrap/Card"

import Layout from "../components/layout"
import addCms from "../cms/index-cms"

function IndexPage(props) {
  let jumbo = addCms(props)
  
  return (
    <Layout>
      <Jumbotron style={{ paddingTop: "1.5em", paddingBottom: "4em" }}>
        <Container>
          <h1 style={{ fontFamily: "HanleyPro-Slim" }}>{jumbo.title}</h1>
          <hr className="my-4" />
          <p className="lead">{jumbo.lead}</p>
          {jumbo.leadtext.split(/[\r\n]/).map((line, index) => (
            <p key={index}>{line}</p>
          )) }
        </Container>
      </Jumbotron>
      <Container id="projects">
        <h1 style={{ fontFamily: "HanleyPro-Slim" }}>Projects</h1>

        <Card className="mb-3">
          <Card.Body>
            <Card.Title as="h2">Quantum Computing</Card.Title>
            <Card.Text as="div"><p>Masters Project - Final year of university - 2008 to 2009</p>
              <h4>The Brief</h4>
              <blockquote>
                <p>&ldquo;The main focus should be</p>
                <ul>
                  <li>the mathematics that describes the particular quantum phenomena that are exploited by (currently mainly theoretical) quantum computers, and</li>
                  <li>the mathematics informing algorithms (like Shor's) that take advantage of the special features of quantum computers
                </li>
                </ul>
                <p>&hellip; you will need to give the reader an insight into the background of quantum mechanics and computer algorithms. You can enliven your account with excursions into the controversial history of quantum physics, the philosophical
                    and psychological difficulties of interpreting quantum phenomena, the story of the visionaries who first saw the potential of quantum computation and believed in the possibility of creating 'machines' to carry it out, and recent
                progress in developing the practical technology to build working quantum computers.&rdquo;</p>
              </blockquote>
              <h4>Presentation</h4>
              <p>Further, a presentation of 25 minutes was given on the topic to a lecture hall of visitors to the university.</p>
              <h4>View Report</h4>
              <p>My report can be downloaded as a pdf: <a href={`/projects/quantum-computing/quantum-computing.pdf`}>quantum-computing.pdf</a></p>
            </Card.Text>
          </Card.Body>
          <Card.Img variant="bottom" src={require('../images/quantum-computing.jpg')} alt="Quantum Computing" style={{ height: "5rem", objectFit: "cover", objectPosition: "left" }} />
        </Card>

        <Card className="mb-3">
          <Card.Body>
            <Card.Title as="h2">Ray Tracing</Card.Title>
            <Card.Text as="div"><p>Second year of university - 2006 to 2007</p>
              <h4>Interest in Ray Tracing</h4>
              <p>The way computers display three dimensional objects on a two dimensional surface! It was a big jump from the command line to drawing on a screen. The starting point for my enquiries was perspective. The mathematics behind this was relatively
            simple, so I soon found myself wondering how to <em>shade</em> these objects. Although <em>ray tracing</em> is not the most computationally quick method of producing a realistic looking image, it is the most physically accurate way
            to do it.</p>
              <h4>Some Simple Classes</h4>
              <p>I began by constructing some classes, first three dimensional vectors, then rays and made sure these could all interact and print suitable information about themselves. These classes can be found here and are free for anyone to use: </p>
              <h4>Basic Ray-Tracing Code</h4>
              <p>I decided to write the code for fixed objects but moving lights. There is normally no animation involved in ray-tracing as it is so slow at generating images. However, using just a sphere, three lights and a small screen size, it is possible
            to generate the images fast enough to see a smooth animation. The code for this is below and can be compiled on any platform with SDL.</p>
              <p>You can view the project on <a href="https://github.com/leonyork/ray-traced-sphere-animation">GitHub</a>.</p>
            </Card.Text>
          </Card.Body>
          <Card.Img variant="bottom" src={require('../images/ray-traced-sphere.jpg')} alt="Ray Traced Sphere" style={{ "height": "7em", objectFit: "cover", objectPosition: "right" }} />
        </Card>
      </Container>

      <Container id="links">
        <div className="card">
          <div className="card-body">
            <h1 className="card-title" style={{ fontFamily: "HanleyPro-Slim" }}>Links</h1>
            <ul>
              <li><a href="http://www.alzheimers.org.uk/about-dementia/types-dementia/alzheimers-disease-symptoms">Never
              forget</a> - Spot the symptoms of Alzheimers early
            </li>
              <li><a href="https://www.meetup.com/leeds_data_platform/">Leeds SQL Server User Group</a></li>
              <li><a href="https://haveibeenpwned.com/">Have I been pwned?</a></li>
            </ul>
          </div>
        </div>
      </Container>
    </Layout>
  )
}

IndexPage.getInitialProps = function (ctx) {
  let jumbo = require(`../content/jumbo.json`)

  return {
    fileRelativePath: `/content/jumbo.json`,
    title: jumbo.title,
    lead: jumbo.lead,
    leadtext: jumbo.leadtext
  }
}

export default IndexPage