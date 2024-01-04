select s.mesano,
sum(s.qca) as qca, sum(s.qca_clinica) as qca_clinica, sum(s.meta_agendamentos) as meta_agendamentos, sum(s.meta_atendimentos) as meta_atendimentos,
sum(s.meta_fat_bruto) as meta_fat_bruto, sum(s.meta_exm_lab) as meta_exm_lab, sum(s.meta_exm_img) as meta_exm_img, sum(s.meta_procedimentos) as meta_procedimentos
from stg_metas s
group by s.mesano 