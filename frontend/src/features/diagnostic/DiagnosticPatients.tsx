import { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { supabase } from '@/shared/lib/supabaseClient';
import { User } from 'phosphor-react';
import styles from './styles/DiagnosticPatients.module.css';

export interface Patient {
    id: string;
    full_name: string;
    email: string;
    phone?: string;
}

interface Props {
    onSelectPatient: (patient: Patient) => void;
}

export default function DiagnosticPatients({ onSelectPatient }: Props) {
    const { t } = useTranslation();
    const [patients, setPatients] = useState<Patient[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchPatients = async () => {
            const { data: { user } } = await supabase.auth.getUser();
            if (!user) return;

            const { data } = await supabase
                .from('diagnostic_patients')
                .select('patient:patient_id(*)')
                .eq('diagnostic_id', user.id);

            if (data) setPatients(data.map((d) => d.patient) as unknown as Patient[]);
            setLoading(false);
        };
        fetchPatients();
    }, []);

    if (loading) return <div>{t('common.loading')}</div>;

    return (
        <div>
            {patients.length === 0 ? <p>{t('dashboard.diagnostic.patients.no_assigned')}</p> : (
                <div className={styles.grid}>
                    {patients.map(p => (
                        <div
                            key={p.id}
                            onClick={() => onSelectPatient(p)}
                            className={styles.card}
                        >
                            <div className={styles.avatar}>
                                <User size={20} color="var(--primary)" />
                            </div>
                            <div className={styles.info}>
                                <h4>{p.full_name}</h4>
                                <small>{p.email}</small>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}