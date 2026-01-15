import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import Navbar from './Navbar';
import Hero from './Hero';
import TrustedPartners from './TrustedPartners';
import Features from './Features';
import Footer from './Footer';
import styles from './styles/LandingPage.module.css';

// Initial Logo Position (Centered & Large)
const initialLogoPosition = {
    top: '50%',
    left: '50%',
    x: '-50%',
    y: '-50%',
    position: 'fixed' as const,
    height: window.innerWidth < 768 ? '280px' : '550px',
    zIndex: 2000,
};

// Target Logo Position (Top-Left & Small) matching Navbar layout
const getTargetPosition = (animate: boolean) => {
    if (!animate) return {};
    const isMobile = window.innerWidth < 768;

    // Adjust these values to match the fixed navbar container padding
    // Navbar container max-width is 1400px.
    // If screen > 1400px, we need to calculate 'left' carefully or just use % if centered.
    // For simplicity, we'll aim for relative positions that generally align visually.

    return {
        top: isMobile ? '18px' : '12px',
        left: isMobile ? '20px' : '5%', // Matches Navbar padding
        x: '0%',
        y: '0%',
        height: isMobile ? '32px' : '48px', // Matches Navbar logo size
    };
};

export default function LandingPage() {
    const [animate, setAnimate] = useState(false);

    useEffect(() => {
        const timer = setTimeout(() => {
            setAnimate(true);
        }, 1000);

        return () => clearTimeout(timer);
    }, []);

    return (
        <div className={styles.container}>
            {/* Logo 1: Visible initially, fades out */}
            <motion.img
                src="/logo1.png"
                alt="HealthSync Logo Start"
                className={styles.floatingLogo}
                initial={{ ...initialLogoPosition, opacity: 1 }}
                animate={{
                    ...getTargetPosition(animate),
                    opacity: animate ? 0 : 1
                }}
                transition={{ duration: 1.5, ease: 'easeInOut' }}
                style={{ pointerEvents: animate ? 'none' : 'auto' }}
            />

            {/* Logo 2: Invisible initially, fades in and moves to position */}
            <motion.img
                src="/icon.png"
                alt="HealthSync Logo Final"
                className={styles.floatingLogo}
                initial={{ ...initialLogoPosition, opacity: 0 }}
                animate={{
                    ...getTargetPosition(animate),
                    opacity: animate ? 1 : 0
                }}
                transition={{ duration: 1.5, ease: 'easeInOut' }}
                onClick={() => animate && window.scrollTo({ top: 0, behavior: 'smooth' })}
            />

            {/* Navbar slides down */}
            <div className={`${styles.navbarWrapper} ${animate ? styles.navbarVisible : ''}`}>
                <Navbar showLogo={animate} />
            </div>

            {/* Content fades in */}
            <div className={`${styles.contentWrapper} ${animate ? styles.contentVisible : ''}`}>
                <Hero />
                <TrustedPartners />
                <Features />
                <Footer />
            </div>
        </div>
    );
}
