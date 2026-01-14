import { format } from 'date-fns';
import { bn } from 'date-fns/locale';
import { FileText, Pill, Syringe } from 'phosphor-react';
import { useTranslation } from 'react-i18next';
import type { MedicalEvent } from '../../types';
import styles from './styles/TimelineTile.module.css';

interface Props {
    event: MedicalEvent;
    isLast: boolean;
}

export default function TimelineTile({ event, isLast }: Props) {
    const { t, i18n } = useTranslation();

    const getIcon = () => {
        switch (event.event_type) {
            case 'PRESCRIPTION': return <Pill size={22} weight="duotone" color="var(--primary)" />;
            case 'VACCINATION': return <Syringe size={22} weight="duotone" color="#059669" />;
            default: return <FileText size={22} weight="duotone" color="#2563EB" />;
        }
    };

    const getBadgeClass = () => {
        switch (event.severity) {
            case 'HIGH': return styles.high;
            case 'MEDIUM': return styles.medium;
            default: return styles.low;
        }
    };

    return (
        <div className={`${styles.container} ${isLast ? styles.lastItem : ''}`}>
            <div className={styles.iconWrapper}>
                {getIcon()}
            </div>

            <div className={styles.card}>
                <div className={styles.header}>
                    <span className={styles.date}>
                        {format(new Date(event.event_date), 'dd MMM yyyy', {
                            locale: i18n.language === 'bn' ? bn : undefined
                        })}
                    </span>
                    <span className={`${styles.badge} ${getBadgeClass()}`}>
                        {t(`severity.${event.severity}`, event.severity)}
                    </span>
                </div>

                <div className={styles.titleRow}>
                    <h3 className={styles.title}>{event.title}</h3>
                    <span className={styles.uploader}>
                        by {event.uploader?.full_name || 'Self'}
                    </span>
                </div>

                {event.summary && <p className={styles.summary}>{event.summary}</p>}

                {event.key_findings && event.key_findings.length > 0 && (
                    <div className={styles.findingsWrapper}>
                        {event.key_findings.map((finding, idx) => (
                            <span key={idx} className={styles.findingChip}>
                                {finding}
                            </span>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}