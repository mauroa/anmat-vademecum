package com.thinkupstudios.anmat.vademecum;

import android.app.Fragment;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TabHost;
import android.widget.TextView;

import com.thinkupstudios.anmat.vademecum.bo.MedicamentoBO;
import com.thinkupstudios.anmat.vademecum.dummy.DummyContent;

/**
 * A fragment representing a single DetalleMedicamento detail screen.
 * This fragment is either contained in a {@link DetalleMedicamentoListActivity}
 * in two-pane mode (on tablets) or a {@link DetalleMedicamentoDetailActivity}
 * on handsets.
 */
public class DetalleMedicamentoDetailFragment extends Fragment {
    /**
     * The fragment argument representing the item ID that this fragment
     * represents.
     */
    public static final String ARG_ITEM_ID = "item_id";

    private MedicamentoBO medicamento;

    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public DetalleMedicamentoDetailFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if(getArguments().containsKey(MedicamentoBO.MEDICAMENTOBO)) {
            this.medicamento = (MedicamentoBO) getArguments().getSerializable(MedicamentoBO.MEDICAMENTOBO);
        }

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_detallemedicamento_detail, container, false);

        this.setValores(rootView, this.medicamento);

        TabHost tabs=(TabHost)rootView.findViewById(android.R.id.tabhost);
        tabs.setup();

        TabHost.TabSpec spec=tabs.newTabSpec("mitab1");
        spec.setContent(R.id.detalle);
        spec.setIndicator("Detalle");
        tabs.addTab(spec);

        spec=tabs.newTabSpec("mitab2");
        spec.setContent(R.id.tab2);
        spec.setIndicator("Formula");
        tabs.addTab(spec);

        tabs.setCurrentTab(0);

        tabs.setOnTabChangedListener(new TabHost.OnTabChangeListener() {
            public void onTabChanged(String tabId) {
                Log.i("AndroidTabsDemo", "Pulsada pestaña: " + tabId);
            }
        });

        return rootView;
    }


    public void setValores(View rootView, MedicamentoBO m){


        ((TextView)rootView.findViewById(R.id.condicion_de_expendioValor)).setText(m.getCondicionExpendio());
        ((TextView)rootView.findViewById(R.id.condicion_de_trazabilidadValor)).setText(m.getCondicionTrazabilidad());
        ((TextView)rootView.findViewById(R.id.forma_farmaceuticaValor)).setText(m.getForma());
        ((TextView)rootView.findViewById(R.id.gtinValor)).setText(m.getGtin());
        ((TextView)rootView.findViewById(R.id.laboratorioValor)).setText(m.getLaboratorio());
        ((TextView)rootView.findViewById(R.id.nombre_comercialValor)).setText(m.getNombreComercial());
        ((TextView)rootView.findViewById(R.id.nombre_generico_Valor)).setText(m.getNombreGenerico());
        ((TextView)rootView.findViewById(R.id.pais_industriaValor)).setText(m.getPaisIndustria());
        ((TextView)rootView.findViewById(R.id.nroCertificadoValor)).setText(m.getNumeroCertificado());
        ((TextView)rootView.findViewById(R.id.presentacionValor)).setText(m.getPresentacion());
        ((TextView)rootView.findViewById(R.id.precioValor)).setText(m.getPrecio());
        ((TextView)rootView.findViewById(R.id.troquelValor)).setText(m.getTroquel());

    }
}
