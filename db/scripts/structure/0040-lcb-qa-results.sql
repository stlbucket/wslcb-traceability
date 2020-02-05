drop table if exists lcb.qa_result cascade;

CREATE TABLE lcb.qa_result (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    lab_app_tenant_id text NOT NULL,
    licensee_app_tenant_id text NOT NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamptz NOT NULL,
    lab_license_holder_id text not null,
    inv_license_holder_id text not null,
    sample_inventory_lot_id text not null,
    results jsonb
);

ALTER TABLE lcb.qa_result OWNER TO app;
ALTER TABLE ONLY lcb.qa_result
    ADD CONSTRAINT pk_qa_result PRIMARY KEY (id);
ALTER TABLE ONLY lcb.qa_result
    ADD CONSTRAINT fk_qa_result_lab_app_tenant_id FOREIGN KEY (lab_app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.qa_result
    ADD CONSTRAINT fk_qa_result_lab_licensee_tenant_id FOREIGN KEY (licensee_app_tenant_id) REFERENCES auth.app_tenant (id);
ALTER TABLE ONLY lcb.qa_result
    ADD CONSTRAINT fk_qa_result_lab_license_holder FOREIGN KEY (lab_license_holder_id) REFERENCES lcb.lcb_license_holder(id);
ALTER TABLE ONLY lcb.qa_result
    ADD CONSTRAINT fk_qa_result_inv_license_holder FOREIGN KEY (inv_license_holder_id) REFERENCES lcb.lcb_license_holder(id);
ALTER TABLE ONLY lcb.qa_result
    ADD CONSTRAINT fk_qa_result_sample_inventory_lot FOREIGN KEY (sample_inventory_lot_id) REFERENCES lcb.inventory_lot(id);


ALTER TABLE ONLY lcb.inventory_lot
    ADD COLUMN qa_result_id text NULL;
ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_qa_result FOREIGN KEY (qa_result_id) REFERENCES lcb.qa_result(id);
