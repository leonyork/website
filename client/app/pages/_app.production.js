import React from 'react'
import App from 'next/app'

import "./fonts.css"
import "./bootstrap.css"

class MyApp extends App {
  constructor() {
    super()
  }

  render() {
    const { Component, pageProps } = this.props
    return (
      <Component {...pageProps} />
    )
  }
}

export default MyApp