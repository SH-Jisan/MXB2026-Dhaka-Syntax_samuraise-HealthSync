import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { supabase } from '@/shared/lib/supabaseClient';
import { formatDistanceToNow } from 'date-fns';
import type { BloodRequest } from '../../types';
import { Drop, Clock, Warning, Heart, User } from 'phosphor-react';
import { bn } from 'date-fns/locale';
import { motion, AnimatePresence } from 'framer-motion';
import styles from './styles/BloodFeed.module.css';

export default function BloodFeed() {
    const { t, i18n } = useTranslation();
    const [requests, setRequests] = useState<BloodRequest[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchRequests();
    }, []);

    const fetchRequests = async () => {
        const { data, error } = await supabase
            .from('blood_requests')
            .select('*, profiles(full_name, phone)')
            .eq('status', 'OPEN')
            .order('created_at', { ascending: false });

        if (!error && data) setRequests(data);
        setLoading(false);
    };

    const handleDonate = async (request: BloodRequest) => {
        if (!confirm(t('blood.feed.confirm_donate'))) return;
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return;

        try {
            const { error } = await supabase.from('request_acceptors').insert({
                request_id: request.id,
                donor_id: user.id
            });

            if (error?.code === '23505') {
                alert(t('blood.feed.already_accepted'));
            } else if (error) {
                throw error;
            } else {
                alert(t('blood.feed.thank_you', { phone: request.profiles?.phone }));
                await fetchRequests();
            }
        } catch (err: unknown) {
            alert(err instanceof Error ? err.message : 'An error occurred');
        }
    };

    if (loading) return (
        <div className={styles.loadingWrapper}>
            <div className={styles.spinner}></div>
            <p>{t('blood.feed.loading')}</p>
        </div>
    );

    return (
        <div className={styles.container}>
            <div className={styles.header}>
                <div className={styles.titleWrapper}>
                    <h2 className={styles.pageTitle}>
                        <span className="t-text-gradient">{t('blood.feed.title')}</span>
                    </h2>
                    <span className={styles.liveBadge}>
                        <span className={styles.pulseDot}></span>
                        LIVE
                    </span>
                </div>
                <p className={styles.subtitle}>{t('blood.feed.subtitle', 'Real-time blood requests from potential recipients.')}</p>
            </div>

            <div className={styles.feedGrid}>
                <AnimatePresence>
                    {requests.length === 0 ? (
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            className={styles.emptyState}
                        >
                            <Drop size={48} weight="duotone" color="#e5e7eb" />
                            <p>{t('blood.feed.no_requests')}</p>
                        </motion.div>
                    ) : (
                        requests.map((req, idx) => {
                            const isCritical = req.urgency === 'CRITICAL';
                            return (
                                <motion.div
                                    key={req.id}
                                    initial={{ opacity: 0, y: 20 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    transition={{ delay: idx * 0.05 }}
                                    className={`${styles.card} t-card-glass ${isCritical ? styles.cardCritical : ''}`}
                                >
                                    <div className={styles.cardHeader}>
                                        <div className={styles.userInfo}>
                                            <div className={styles.avatar}>
                                                <User weight="fill" />
                                            </div>
                                            <div>
                                                <div className={styles.requesterName}>
                                                    {req.profiles?.full_name || t('common.unknown')}
                                                </div>
                                                <div className={styles.timeInfo}>
                                                    <Clock size={14} />
                                                    {req.created_at && formatDistanceToNow(new Date(req.created_at), {
                                                        addSuffix: true,
                                                        locale: i18n.language === 'bn' ? bn : undefined
                                                    })}
                                                </div>
                                            </div>
                                        </div>
                                        {isCritical && (
                                            <div className={styles.criticalBadge}>
                                                <Warning size={16} weight="fill" />
                                                {t('blood.request.critical')}
                                            </div>
                                        )}
                                    </div>

                                    <div className={styles.cardBody}>
                                        <div className={styles.bloodGroupWrapper}>
                                            <div className={`${styles.bloodGroup} ${isCritical ? styles.bgCritical : ''}`}>
                                                {req.blood_group}
                                            </div>
                                        </div>
                                        <div className={styles.requestDetails}>
                                            <h3 className={styles.hospitalName}>{req.hospital_name}</h3>
                                            {req.reason && <p className={styles.reasonBox}>"{req.reason}"</p>}

                                            <div className={styles.progressContainer} style={{ marginTop: '1rem' }}>
                                                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px', fontSize: '0.8rem', fontWeight: 600 }}>
                                                    <span style={{ color: 'var(--text-secondary)' }}>
                                                        {t('blood.feed.donors_found', 'Donors Found')} ({req.accepted_count || 0}/3)
                                                    </span>
                                                    <span style={{ color: 'var(--primary)' }}>
                                                        {Math.min(100, Math.round(((req.accepted_count || 0) / 3) * 100))}%
                                                    </span>
                                                </div>
                                                <div style={{ width: '100%', height: '6px', background: 'var(--surface-border)', borderRadius: '4px', overflow: 'hidden' }}>
                                                    <div style={{
                                                        width: `${Math.min(100, ((req.accepted_count || 0) / 3) * 100)}%`,
                                                        height: '100%',
                                                        background: 'var(--primary)',
                                                        borderRadius: '4px',
                                                        transition: 'width 0.5s ease'
                                                    }}></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div className={styles.cardFooter}>
                                        <button
                                            onClick={() => handleDonate(req)}
                                            className={`${styles.donateBtn} ${isCritical ? styles.btnCritical : ''}`}
                                        >
                                            <Heart size={20} weight="fill" />
                                            <span>{t('blood.feed.donate_btn')}</span>
                                        </button>
                                    </div>
                                </motion.div>
                            );
                        })
                    )}
                </AnimatePresence>
            </div>
        </div>
    );
}