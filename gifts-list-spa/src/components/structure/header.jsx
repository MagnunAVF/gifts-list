import React from 'react'
import { Navbar, Nav } from 'react-bootstrap'

const Header = () => (
    <header>
        <Navbar bg="white" expand="lg">
            <Navbar.Brand href="/">
                HOME
            </Navbar.Brand>
            <Navbar.Toggle aria-controls="basic-navbar-nav" />
            <Navbar.Collapse id="basic-navbar-nav">
                <Nav className="mr-auto">
                    <Nav.Link href="/">Página Inicial</Nav.Link>
                </Nav>
            </Navbar.Collapse>
        </Navbar>
    </header>
)

export default Header