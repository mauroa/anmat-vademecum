package com.thinkupstudios.anmat.vademecum;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.TextView;

import com.thinkupstudios.anmat.vademecum.bo.FormularioBusqueda;
import com.thinkupstudios.anmat.vademecum.providers.tables.ComercialesTable;
import com.thinkupstudios.anmat.vademecum.providers.GenericProvider;
import com.thinkupstudios.anmat.vademecum.providers.tables.GenericoTable;
import com.thinkupstudios.anmat.vademecum.providers.helper.DatabaseHelper;
import com.thinkupstudios.anmat.vademecum.providers.tables.LaboratorioTable;

import java.util.List;


public class BusquedaMedicamentoActivity extends Activity implements View.OnClickListener, AdapterView.OnItemSelectedListener {

    private FormularioBusqueda formualario = new FormularioBusqueda();
    private AutoCompleteTextView laboratorio;
    private AutoCompleteTextView nombreComercial;
    private AutoCompleteTextView nombreGenerico;
    private Button buscarBtn;
    private GenericProvider laboratoriosProvider;
    private GenericProvider genericosProvider;
    private GenericProvider comercialesProvider;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_busqueda_medicamento);
        laboratoriosProvider = new GenericProvider(new DatabaseHelper(this));
        genericosProvider = new GenericProvider(new DatabaseHelper(this));
        comercialesProvider = new GenericProvider(new DatabaseHelper(this));
        buscarBtn = (Button) findViewById(R.id.btn_form_busqueda_buscar);
        buscarBtn.setOnClickListener(this);
        buscarBtn.setImeOptions(EditorInfo.IME_ACTION_DONE);

        this.laboratorio = (AutoCompleteTextView) findViewById(R.id.txt_laboratorio);
        ArrayAdapter<String> dataAdapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, laboratoriosProvider.getAllCollumnName(LaboratorioTable.TABLE_NAME, LaboratorioTable.COLUMNS));
        dataAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        laboratorio.setAdapter(dataAdapter);


        this.nombreGenerico = (AutoCompleteTextView) findViewById(R.id.txt_nombre_generico);
        List<String> genericos = this.genericosProvider.getAllCollumnName(GenericoTable.TABLE_NAME, GenericoTable.COLUMNS);
        ArrayAdapter adapterCom = new ArrayAdapter
                (this,android.R.layout.simple_list_item_1,genericos);
        adapterCom.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        this.nombreGenerico.setAdapter(adapterCom);

        this.nombreComercial = (AutoCompleteTextView) findViewById(R.id.txt_nombre_comercial);
        List<String> comerciales = this.comercialesProvider.getAllCollumnName(ComercialesTable.TABLE_NAME, ComercialesTable.COLUMNS);
        ArrayAdapter adapterGen = new ArrayAdapter
                (this,android.R.layout.simple_list_item_1,comerciales);
        adapterCom.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        this.nombreComercial.setAdapter(adapterGen);

    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.main_menu, menu);
        return super.onCreateOptionsMenu(menu);
    }


    @Override
    public void onClick(View v) {
        Button b = (Button) v;
        Intent i = new Intent(this, DetalleMedicamentoListActivity.class);
        this.formualario.setNombreGenerico(this.nombreGenerico.getText().toString());
        this.formualario.setNombreComercial(this.nombreComercial.getText().toString());
        this.formualario.setLaboratorio(this.laboratorio.getText().toString());
        i.putExtra(FormularioBusqueda.FORMULARIO_MANUAL,this.formualario);
        startActivity(i);
        overridePendingTransition(R.anim.abc_fade_in,R.anim.abc_fade_out);

    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        //this.formualario.setLaboratorio(((TextView)view).getText().toString());
    }

    @Override
    public void onNothingSelected(AdapterView<?> parent) {

    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        switch (id) {
            case R.id.mnu_buscar:
                startActivity(new Intent(this, BusquedaMedicamentoActivity.class));
                return true;
            case android.R.id.home:
                NavUtils.navigateUpFromSameTask(this);
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    class MyEditorActionListener implements TextView.OnEditorActionListener{
        @Override
        public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
            if(actionId == EditorInfo.IME_ACTION_DONE){
                buscarBtn.performClick();
                return true;
            }
            return false;
        }
    }
}
