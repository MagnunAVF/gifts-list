import React from 'react'
import { render } from 'react-dom'
import { BrowserRouter } from 'react-router-dom'

import App from './components/structure/app';

render((
    <BrowserRouter>
        <App />
    </BrowserRouter>
), document.getElementById('app'));