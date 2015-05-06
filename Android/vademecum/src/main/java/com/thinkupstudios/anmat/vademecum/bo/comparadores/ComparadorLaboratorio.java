package com.thinkupstudios.anmat.vademecum.bo.comparadores;

import com.thinkupstudios.anmat.vademecum.bo.MedicamentoBO;

import java.util.Comparator;

/**
 * Created by fcostazini on 06/05/2015.
 */
public class ComparadorLaboratorio implements Comparator<MedicamentoBO> {
    @Override
    public int compare(MedicamentoBO lhs, MedicamentoBO rhs) {
        return lhs.getLaboratorio().compareTo(rhs.getLaboratorio());
    }
}
