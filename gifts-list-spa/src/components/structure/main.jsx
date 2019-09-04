import React from 'react'
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom'

import Home from './../pages/home'

const Main = () => (
    <main>
        <div className="main-content">
            <Router>
                <Switch>
                    <Route exact path='/' component={Home} />
                </Switch>
            </Router>
        </div>
    </main >
)

export default Main