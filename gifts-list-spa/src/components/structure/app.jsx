import React from 'react'

import Header from './header'
import Main from './main'
import Footer from './footer'

import 'bootstrap/dist/css/bootstrap.css'
import './../../assets/stylesheets/index.scss'

import { library } from '@fortawesome/fontawesome-svg-core'
import { faStroopwafel } from '@fortawesome/free-solid-svg-icons'
library.add(faStroopwafel)

const App = () => (
    <div>
        <Header />
        <Main />
        <Footer />
    </div>
)

export default App