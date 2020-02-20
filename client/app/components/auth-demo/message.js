import React, { Component } from "react"

import Form from "react-bootstrap/Form"
import Button from "react-bootstrap/Button"
import Card from "react-bootstrap/Card"

import { Transition } from "react-transition-group"

import styles from "./message.module.css"

export default class Message extends Component {

    defaultMessage = "Hello!"

    constructor(props) {
        super(props);
        this.state = {
            sub: undefined,
            message: this.props.defaultMessage || this.defaultMessage,
            messageLoaded: false
        };
        this.handleChange = this.handleChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    async componentDidMount() {
        const userInfo = await this.userInfo()
        this.setState({
            sub: userInfo.sub
        })
        const message = await this.message(userInfo.sub)
        this.setState({ messageLoaded: true })
        message && this.setState({ message: message })
    }

    async userInfo() {
        const accessToken = this.props.accessToken
        if (!accessToken) {
            return undefined
        }
        const response = await fetch(
            `${process.env.REACT_APP_COGNITO_HOST}/oauth2/userInfo`,
            { headers: { Authorization: `Bearer ${accessToken}` } }
        );
        return response.json();
    }

    async message(sub) {
        const response = await fetch(
            `${process.env.REACT_APP_USER_API_URL}/user/${sub}`,
            { headers: { Authorization: `Bearer ${this.props.accessToken}` } }
        );
        if (response.status == 404) {
            return Promise.resolve(undefined);
        }
        return (await response.json()).message
    }

    handleChange(event) {
        this.setState({ message: event.target.value });
    }

    async handleSubmit(event) {
        event.preventDefault();
        const response = await fetch(
            `${process.env.REACT_APP_USER_API_URL}/user/${this.state.sub}`,
            {
                method: "PUT",
                body: JSON.stringify({ message: this.state.message }),
                headers: { Authorization: `Bearer ${this.props.accessToken}` }
            }
        );
        this.setState({
            message: (await response.json()).message
        })
    }

    render() {
        return (
            <>
                <Transition in={this.state.messageLoaded} timeout={500}>
                    {state => (
                        <div className={styles[state]}>
                            <h2>{this.state.message}</h2>
                        </div>
                    )}
                </Transition>
                <Transition in={this.state.sub !== undefined} timeout={500}>
                    {state => (
                        <div className={styles[state]}>
                            <p>Your user id is {this.state.sub}</p>
                        </div>
                    )}
                </Transition>

                <Transition in={this.state.messageLoaded} timeout={500}>
                    {state => (
                        <Card className={styles[state]}>
                            <Card.Header>Your welcome message</Card.Header>
                            <Card.Body>
                                <Form onSubmit={this.handleSubmit}>
                                    <Form.Group controlId="formMessage">
                                        <Form.Label>Message</Form.Label>
                                        <Form.Control type="text" placeholder="Message" value={this.state.message} onChange={this.handleChange} />
                                    </Form.Group>
                                    <Button variant="primary" type="submit" value="Submit">Save</Button>
                                </Form>
                            </Card.Body>
                        </Card>
                    )}
                </Transition>
            </>
        )
    }

}