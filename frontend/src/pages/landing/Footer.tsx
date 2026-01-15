import { useTranslation } from 'react-i18next';
import { FacebookLogo, TwitterLogo, LinkedinLogo, InstagramLogo } from 'phosphor-react';
import styles from './styles/Footer.module.css';

export default function Footer() {
    const { t } = useTranslation();

    return (
        <footer className={styles.footer} id="contact">
            <div className={styles.content}>
                {/* Brand Column */}
                <div className={styles.column}>
                    <h3>{t('common.health_sync')}</h3>
                    <p className={styles.description}>
                        {t('landing.footer_desc')}
                    </p>
                    <div className={styles.socialRow}>
                        <a href="#" className={styles.socialIcon}><FacebookLogo size={20} weight="fill" /></a>
                        <a href="#" className={styles.socialIcon}><TwitterLogo size={20} weight="fill" /></a>
                        <a href="#" className={styles.socialIcon}><LinkedinLogo size={20} weight="fill" /></a>
                        <a href="#" className={styles.socialIcon}><InstagramLogo size={20} weight="fill" /></a>
                    </div>
                </div>

                {/* Services Column */}
                <div className={styles.column}>
                    <h3>{t('landing.footer_services')}</h3>
                    <ul>
                        <li><a href="#">{t('landing.s1')}</a></li>
                        <li><a href="#">{t('landing.s2')}</a></li>
                        <li><a href="#">{t('landing.s3')}</a></li>
                        <li><a href="#">{t('landing.s4')}</a></li>
                    </ul>
                </div>

                {/* Company Column */}
                <div className={styles.column}>
                    <h3>{t('landing.footer_company')}</h3>
                    <ul>
                        <li><a href="#">{t('landing.c1')}</a></li>
                        <li><a href="#">{t('landing.c2')}</a></li>
                        <li><a href="#">{t('landing.c3')}</a></li>
                        <li><a href="#">{t('landing.c4')}</a></li>
                    </ul>
                </div>

                {/* Legal/Support Column */}
                <div className={styles.column}>
                    <h3>Support</h3>
                    <ul>
                        <li><a href="#">Help Center</a></li>
                        <li><a href="#">Frequently Asked Questions</a></li>
                        <li><a href="#">Terms & Conditions</a></li>
                        <li><a href="#">Privacy Policy</a></li>
                    </ul>
                </div>
            </div>

            <div className={styles.bottom}>
                <span>&copy; {new Date().getFullYear()} {t('common.health_sync')}. {t('landing.rights')}</span>
                <div style={{ display: 'flex', gap: '20px' }}>
                    <a href="#" style={{ color: 'inherit', textDecoration: 'none' }}>Privacy</a>
                    <a href="#" style={{ color: 'inherit', textDecoration: 'none' }}>Terms</a>
                </div>
            </div>
        </footer>
    );
}
