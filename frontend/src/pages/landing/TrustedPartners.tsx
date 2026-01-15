import { useTranslation } from 'react-i18next';
import { Buildings, Handshake, FirstAidKit, Globe, Heartbeat, UserGear } from 'phosphor-react';
import styles from './styles/TrustedPartners.module.css';

export default function TrustedPartners() {
    const { t } = useTranslation();

    const partners = [
        { icon: <Buildings size={32} weight="duotone" />, name: t('landing.p1') },
        { icon: <Handshake size={32} weight="duotone" />, name: t('landing.p2') },
        { icon: <FirstAidKit size={32} weight="duotone" />, name: t('landing.p3') },
        { icon: <Globe size={32} weight="duotone" />, name: t('landing.p4') },
        { icon: <Heartbeat size={32} weight="duotone" />, name: "MedLife" },
        { icon: <UserGear size={32} weight="duotone" />, name: "DoctorPlus" },
    ];

    return (
        <section className={styles.section}>
            <h3 className={styles.title}>{t('landing.partners_title')}</h3>

            <div className={styles.marqueeContainer}>
                {/* Track moves left */}
                <div className={styles.marqueeTrack}>
                    {/* Render Twice for seamless loop */}
                    {[...partners, ...partners, ...partners].map((partner, index) => (
                        <div key={index} className={styles.partner}>
                            {partner.icon}
                            <span>{partner.name}</span>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    );
}
