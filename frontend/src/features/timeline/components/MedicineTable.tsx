import React from 'react';
import { Pill, WarningCircle } from 'phosphor-react';
import styles from '../styles/EventDetailsModal.module.css';
import type { MedicalEvent } from '../../../types'; // Assuming types are in the parent features folder or similar


interface MedicineTableProps {
    medicines: MedicalEvent['medicines'];
}

const MedicineTable = React.memo(({ medicines }: MedicineTableProps) => {
    return (
        <div className={`${styles.innerContent} ${styles.medicineTableWrapper}`}>
            {medicines && medicines.length > 0 ? (
                <table className={styles.medTable}>
                    <thead>
                        <tr>
                            <th>Medicine Name</th>
                            <th>Dosage</th>
                            <th>Duration</th>
                        </tr>
                    </thead>
                    <tbody>
                        {medicines.map((med: any, idx: number) => (
                            <tr key={idx}>
                                <td><div className={styles.medName}><Pill color="var(--primary)" /> {med.name}</div></td>
                                <td>{med.dosage || '-'}</td>
                                <td>{med.duration || '-'}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            ) : (
                <div className={styles.emptyState}>
                    <div style={{ color: '#94A3B8' }}>
                        <WarningCircle size={48} style={{ opacity: 0.5, marginBottom: '10px' }} />
                        <p>No structured medicine data found.</p>
                    </div>
                </div>
            )}
        </div>
    );
});

export default MedicineTable;
