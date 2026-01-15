import React from 'react';
import { WarningCircle, Info } from 'phosphor-react';
import styles from '../styles/EventDetailsModal.module.css';

interface DiseaseInsightProps {
    insight: string | any;
}

const DiseaseInsight = React.memo(({ insight }: DiseaseInsightProps) => {
    if (!insight) return null;

    // If simple string
    if (typeof insight === 'string') {
        return <div className={styles.diseaseText}>{insight}</div>;
    }

    // If Object (Structured)
    return (
        <div className={styles.structuredInsight}>
            <div className={styles.insightHeader}>
                <h4>{insight.disease_name} <span className={styles.localName}>({insight.local_name})</span></h4>
                {insight.seriousness && (
                    <span className={`${styles.seriousnessBadge} ${styles[insight.seriousness.toLowerCase()]}`}>
                        {insight.seriousness}
                    </span>
                )}
            </div>

            {insight.symptoms && insight.symptoms.length > 0 && (
                <div className={styles.insightSection}>
                    <strong><WarningCircle size={14} /> Symptoms:</strong>
                    <p>{Array.isArray(insight.symptoms) ? insight.symptoms.join(', ') : insight.symptoms}</p>
                </div>
            )}

            {insight.causes && insight.causes.length > 0 && (
                <div className={styles.insightSection}>
                    <strong><Info size={14} /> Causes:</strong>
                    <p>{Array.isArray(insight.causes) ? insight.causes.join(', ') : insight.causes}</p>
                </div>
            )}
        </div>
    );
});

export default DiseaseInsight;
