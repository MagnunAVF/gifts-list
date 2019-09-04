import React from 'react'
import { Tooltip, OverlayTrigger } from 'react-bootstrap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faCodeBranch } from '@fortawesome/free-solid-svg-icons'

const Footer = () => (
    <footer>
        <div className="container d-flex justify-content-center">
            <span className="footer-text">desenvolvido por MagnunAVF </span>
            <OverlayTrigger
                overlay={
                    <Tooltip>
                        Github
          </Tooltip>
                } >
                <a href="https://github.com/magnunAVF">
                    <FontAwesomeIcon icon={faCodeBranch} color="white" />
                </a>
            </OverlayTrigger>
        </div>
    </footer>
)

export default Footer