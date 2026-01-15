import React from 'react';
import { format, isValid } from 'date-fns';
import { ShieldCheck, Warning, WarningCircle } from 'phosphor-react';
import styles from '../styles/EventDetailsModal.module.css';
import type { MedicalEvent } from '../../../types';
import DiseaseInsight from './DiseaseInsight';

interface PrintablePrescriptionProps {
    event: MedicalEvent;
    simpleExplanation?: string;
    diseaseInsight?: any;
    safetyStatus?: string;
}

const safeFormat = (dateString: string | undefined, dateFormat: string) => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return isValid(date) ? format(date, dateFormat) : 'Invalid Date';
};

const getSafetyBadge = (status: string) => {
    if (status === 'Safe') return <span className={`${styles.safetyBadge} ${styles.safe}`}><ShieldCheck size={16} weight="fill" /> Safe</span>;
    if (status === 'Caution') return <span className={`${styles.safetyBadge} ${styles.caution}`}><Warning size={16} weight="fill" /> Caution</span>;
    if (status === 'Danger') return <span className={`${styles.safetyBadge} ${styles.danger}`}><WarningCircle size={16} weight="fill" /> Danger</span>;
    return null;
};

const PrintablePrescription = React.forwardRef<HTMLDivElement, PrintablePrescriptionProps>((
    { event, simpleExplanation, diseaseInsight, safetyStatus },
    ref
) => {
    return (
        <div className={styles.printOnly} ref={ref}>
            <div className={styles.prescriptionView}>
                <div className={styles.prescriptionHeader}>
                    <div className={styles.brand}>
                        <h1>HealthSync</h1>
                        <p>Smart Healthcare Solution</p>
                    </div>
                    <div className={styles.docInfo}>
                        <h3>Dr. {event.uploader?.full_name}</h3>
                        <p>{event.uploader?.specialty}</p>
                        <p>{safeFormat(event.event_date, 'dd MMM yyyy')}</p>
                    </div>
                </div>

                <div className={styles.patientBar}>
                    <span><strong>Patient:</strong> {event.profiles?.full_name}</span>
                    <span><strong>Phone:</strong> {event.profiles?.phone}</span>
                </div>

                <div className={styles.rxSection}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <h2>Rx</h2>
                        {safetyStatus && getSafetyBadge(safetyStatus)}
                    </div>

                    <div className={styles.rxList}>
                        {event.medicines && event.medicines.length > 0 ? (
                            event.medicines.map((med: any, i: number) => (
                                <div key={i} className={styles.medItem}>
                                    <strong>{med.name}</strong>
                                    <span>{med.dosage} — {med.duration}</span>
                                </div>
                            ))
                        ) : (
                            <p>{event.summary || event.extracted_text}</p>
                        )}
                    </div>
                </div>

                {/* Show AI Summary on Prescription if available */}
                {(simpleExplanation || event.summary) && (
                    <div className={styles.adviceBox}>
                        <h4>AI Summary:</h4>
                        <p>{simpleExplanation || event.summary}</p>
                    </div>
                )}

                {/* Print Disease Insight if available */}
                {diseaseInsight && (
                    <div className={styles.adviceBox} style={{ marginTop: '20px', background: '#eef2ff', borderLeftColor: '#4338ca' }}>
                        <h4>Possible Condition:</h4>
                        <DiseaseInsight insight={diseaseInsight} />
                    </div>
                )}

                <div className={styles.signatureArea}>
                    <div className={styles.sigLine}></div>
                    <p>Doctor's Signature</p>
                </div>
            </div>
        </div>
    );
});

export default React.memo(PrintablePrescription);
